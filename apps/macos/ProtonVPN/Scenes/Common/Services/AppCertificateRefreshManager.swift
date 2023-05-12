//
//  Created on 2022-02-23.
//
//  Copyright (c) 2022 Proton AG
//
//  ProtonVPN is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonVPN is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonVPN.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import vpncore
import VPNShared

protocol AppCertificateRefreshManagerFactory {
    func makeAppCertificateRefreshManager() -> AppCertificateRefreshManager
}

final class AppCertificateRefreshManager {

    /// Last time interval that was waited before retry on API error. Will be increased by `nextRetryBackoff()`.
    private var lastRetryInterval: TimeInterval = 10

    private var appSessionManager: AppSessionManager
    private var vpnAuthenticationStorage: VpnAuthenticationStorage
    private var timer: Timer?

    init(appSessionManager: AppSessionManager, vpnAuthenticationStorage: VpnAuthenticationStorage) {
        self.appSessionManager = appSessionManager
        self.vpnAuthenticationStorage = vpnAuthenticationStorage
        self.vpnAuthenticationStorage.delegate = self
    }

    func planNextRefresh() {
        guard let certificate = vpnAuthenticationStorage.getStoredCertificate() else {
            log.info("No current certificate, will try to generate new certificate right now.", category: .userCert)
            refreshCertificate()
            return
        }

        var nextRefreshTime = certificate.refreshTime

        if nextRefreshTime <= Date() {
            log.info("Current certificate should've been refreshed at \(nextRefreshTime). Starting refresh right now.", category: .userCert)
            nextRefreshTime = Date()
        }

        startTimer(at: nextRefreshTime)
    }

    @objc private func refreshCertificate() {
        appSessionManager.refreshVpnAuthCertificate(success: {
            self.lastRetryInterval = 10
            // Planning next refresh happens in `certificateStored()`

        }, failure: { error in
            let delay = self.nextRetryBackoff()
            log.error("Failed to refresh certificate through API: \(error). Will retry in \(delay) seconds.", category: .userCert)
            self.startTimer(at: Date().addingTimeInterval(delay))
        })
    }

    private func nextRetryBackoff() -> TimeInterval {
        lastRetryInterval *= 2
        return lastRetryInterval
    }

    private func startTimer(at nextRunTime: Date) {
        stopTimer()
        timer = Timer.scheduledTimer(timeInterval: nextRunTime.timeIntervalSince(Date()), target: self, selector: #selector(refreshCertificate), userInfo: nil, repeats: false)
        log.info("Timer setup for \(nextRunTime)", category: .userCert)
    }

    private func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            log.info("Certificate refresh timer invalidated", category: .userCert)
        }
        timer = nil
    }
}

extension AppCertificateRefreshManager: VpnAuthenticationStorageDelegate {

    func certificateDeleted() {
        stopTimer()
    }

    func certificateStored(_ certificate: VpnCertificate) {
        planNextRefresh()
    }

}
