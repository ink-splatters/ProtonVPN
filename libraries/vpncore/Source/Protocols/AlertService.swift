//
//  AlertService.swift
//  vpncore - Created on 26.06.19.
//
//  Copyright (c) 2019 Proton Technologies AG
//
//  This file is part of vpncore.
//
//  vpncore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  vpncore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with vpncore.  If not, see <https://www.gnu.org/licenses/>.

import Foundation

public enum PrimaryActionType {
    case confirmative
    case destructive
    case secondary
    case cancel
}

public protocol CoreAlertServiceFactory {
    func makeCoreAlertService() -> CoreAlertService
}

public protocol CoreAlertService: class {
    func push(alert: SystemAlert)
}

public protocol UIAlertServiceFactory {
    func makeUIAlertService() -> UIAlertService
}

public protocol UIAlertService: class {
    func displayAlert(_ alert: SystemAlert)
    func displayAlert(_ alert: SystemAlert, message: NSAttributedString)
    func displayNotificationStyleAlert(message: String, type: NotificationStyleAlertType, accessibilityIdentifier: String?)
}

// Add default value to `accessibilityIdentifier`
extension UIAlertService {
    func displayNotificationStyleAlert(message: String, type: NotificationStyleAlertType) {
        return displayNotificationStyleAlert(message: message, type: type, accessibilityIdentifier: nil)
    }
}

public enum NotificationStyleAlertType {
    case error
    case success
}

public struct AlertAction {
    public let title: String
    public let style: PrimaryActionType
    public let handler: (() -> Void)?
    
    public init(title: String, style: PrimaryActionType, handler: (() -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

public protocol SystemAlert: AnyObject {
    var title: String? { get set }
    var message: String? { get set }
    var actions: [AlertAction] { get set }
    var isError: Bool { get }
    var dismiss: (() -> Void)? { get set }
}

public protocol UserAccountUpdateAlert: SystemAlert {
    var imageName: String? { get }
    var reconnectionInfo: VpnReconnectInfo? { get }
    var displayFeatures: Bool { get }
}

public protocol ExpandableSystemAlert: SystemAlert {
    var expandableInfo: String? { get set }
    var footInfo: String? { get set }
}

extension SystemAlert {
    public static var className: String {
        return String(describing: self)
    }
    
    public var className: String {
        return String(describing: type(of: self))
    }
}

/// App should update to be able to use API
public class AppUpdateRequiredAlert: SystemAlert {
    public var title: String? = LocalizedString.updateRequired
    public var message: String? = LocalizedString.updateRequiredNoLongerSupported
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    
    public init(_ apiError: ApiError) {
        message = apiError.localizedDescription
    }
}

public class CannotAccessVpnCredentialsAlert: SystemAlert {
    public var title: String?
    public var message: String?
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?

    public init() { }
}

public class ExistingConnectionAlert: SystemAlert {
    public var title: String? = LocalizedString.existingSession
    public var message: String? = LocalizedString.existingSessionToServer
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
}

public class FirstTimeConnectingAlert: SystemAlert {
    public var title: String?
    public var message: String?
    public var actions = [AlertAction]()
    public let isError: Bool = false
    public var dismiss: (() -> Void)?
}

public class P2pBlockedAlert: SystemAlert {
    public var title: String? = LocalizedString.p2pDetectedPopupTitle
    public var message: String? = LocalizedString.p2pDetectedPopupBody
    public var actions = [AlertAction]()
    public let isError: Bool = false
    public var dismiss: (() -> Void)?
}

public class P2pForwardedAlert: SystemAlert {
    public var title: String? = LocalizedString.p2pForwardedPopupTitle
    public var message: String? = LocalizedString.p2pForwardedPopupBody
    public var actions = [AlertAction]()
    public let isError: Bool = false
    public var dismiss: (() -> Void)?
}

public class RefreshTokenExpiredAlert: SystemAlert {
    public var title: String?
    public var message: String?
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?

    public init() { }
}

public class UpgradeUnavailableAlert: SystemAlert {
    public var title: String? = LocalizedString.upgradeUnavailableTitle
    public var message: String? = LocalizedString.upgradeUnavailableBody
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    
    public init() {
        let confirmHandler: () -> Void = {
            SafariService.openLink(url: CoreAppConstants.ProtonVpnLinks.accountDashboard)
        }
        actions.append(AlertAction(title: LocalizedString.account, style: .confirmative, handler: confirmHandler))
        actions.append(AlertAction(title: LocalizedString.cancel, style: .cancel, handler: nil))
    }
}

public class DelinquentUserAlert: SystemAlert {
    public var title: String? = LocalizedString.delinquentUserTitle
    public var message: String? = LocalizedString.delinquentUserDescription
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    
    public init() { }
}

public class VpnStuckAlert: SystemAlert {
    public var title: String? = LocalizedString.vpnStuckDisconnectingTitle
    public var message: String? = LocalizedString.vpnStuckDisconnectingBody
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    
    public init() {}
}

public class VpnNetworkUnreachableAlert: SystemAlert {
    public var title: String? = LocalizedString.notConnectedToTheInternet
    public var message: String?
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
}

public class MaintenanceAlert: SystemAlert {
    public var title: String? = LocalizedString.allServersInProfileUnderMaintenance
    public var message: String?
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    public let type: MaintenanceAlertType
    
    public init() {
        title = LocalizedString.allServersInProfileUnderMaintenance
        type = .alert
    }
    
    public init(countryName: String) {
        title = LocalizedString.countryServersUnderMaintenance(countryName)
        type = .alert
    }

    public init(cityName: String) {
        title = LocalizedString.countryServersUnderMaintenance(cityName)
        type = .alert
    }
    
    /// If `forSpecificCountry` is set, switches between country and servers texts, if it's nil, uses one text
    public init(forSpecificCountry: Bool?) {
        if let forSpecificCountry = forSpecificCountry {
            title = forSpecificCountry ? LocalizedString.allServersInCountryUnderMaintenance : LocalizedString.allServersUnderMaintenance
        } else {
            title = LocalizedString.serverUnderMaintenance
        }
        type = .notification
    }
    
    public enum MaintenanceAlertType {
        case alert
        case notification
    }
}

public class SecureCoreToggleDisconnectAlert: SystemAlert {
    public var title: String? = LocalizedString.warning
    public var message: String? = LocalizedString.viewToggleWillCauseDisconnect
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    
    public init(confirmHandler: @escaping () -> Void, cancelHandler: @escaping () -> Void) {
        actions.append(AlertAction(title: LocalizedString.continue, style: .confirmative, handler: confirmHandler))
        actions.append(AlertAction(title: LocalizedString.cancel, style: .cancel, handler: cancelHandler))
    }    
}

public class ChangeProtocolDisconnectAlert: SystemAlert {
    public var title: String? = LocalizedString.vpnConnectionActive
    public var message: String? = LocalizedString.changeProtocolDisconnectWarning
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    
    public init(confirmHandler: @escaping () -> Void) {
        actions.append(AlertAction(title: LocalizedString.continue, style: .confirmative, handler: confirmHandler))
        actions.append(AlertAction(title: LocalizedString.cancel, style: .cancel, handler: nil))
    }
}

public class ReconnectOnSettingsChangeAlert: SystemAlert {
    public struct UserCancelledReconnect: Error, CustomStringConvertible {
        public let description = "User was changing settings, but cancelled reconnecting."
    }
    public static let userCancelled = UserCancelledReconnect()

    public var title: String? = LocalizedString.changeSettings
    public var message: String? = LocalizedString.reconnectOnSettingsChangeBody
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    
    public init(confirmHandler: @escaping () -> Void, cancelHandler: (() -> Void)? = nil) {
        actions.append(AlertAction(title: LocalizedString.continue, style: .confirmative, handler: confirmHandler))
        actions.append(AlertAction(title: LocalizedString.cancel, style: .cancel, handler: cancelHandler))
    }
}

public class ReconnectOnActionAlert: SystemAlert {
    public var title: String?
    public var message: String? = LocalizedString.actionRequiresReconnect
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    
    public init(actionTitle: String, confirmHandler: @escaping () -> Void, cancelHandler: (() -> Void)? = nil) {
        title = actionTitle
        actions.append(AlertAction(title: LocalizedString.continue, style: .confirmative, handler: confirmHandler))
        actions.append(AlertAction(title: LocalizedString.cancel, style: .cancel, handler: cancelHandler))
    }
}

public class TurnOnKillSwitchAlert: SystemAlert {
    public var title: String? = LocalizedString.turnKsOnTitle
    public var message: String? = LocalizedString.turnKsOnDescription
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    
    public init(confirmHandler: @escaping () -> Void, cancelHandler: (() -> Void)? = nil) {
        actions.append(AlertAction(title: LocalizedString.continue, style: .confirmative, handler: confirmHandler))
        actions.append(AlertAction(title: LocalizedString.notNow, style: .cancel, handler: cancelHandler))
    }
}

public class AllowLANConnectionsAlert: SystemAlert {
    public var title: String? = LocalizedString.allowLanTitle
    public var message: String? = LocalizedString.allowLanDescription
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    
    public init(connected: Bool, confirmHandler: @escaping () -> Void, cancelHandler: (() -> Void)? = nil) {
        if connected {
            message! += "\n\n" + LocalizedString.allowLanNote
        }
        actions.append(AlertAction(title: LocalizedString.continue, style: .confirmative, handler: confirmHandler))
        actions.append(AlertAction(title: LocalizedString.notNow, style: .cancel, handler: cancelHandler))
    }
}

public class ReconnectOnSmartProtocolChangeAlert: SystemAlert {
    public struct UserCancelledReconnect: Error, CustomStringConvertible {
        public let description = "User selected smart protocol, but cancelled reconnecting."
    }
    public static let userCancelled = UserCancelledReconnect()

    public var title: String? = LocalizedString.smartProtocolReconnectModalTitle
    public var message: String? = LocalizedString.smartProtocolReconnectModalBody
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?

    public init(confirmHandler: @escaping () -> Void, cancelHandler: (() -> Void)? = nil) {
        actions.append(AlertAction(title: LocalizedString.continue, style: .confirmative, handler: confirmHandler))
        actions.append(AlertAction(title: LocalizedString.cancel, style: .cancel, handler: cancelHandler))
    }
}

public class LogoutWarningAlert: SystemAlert {
    public var title: String? = LocalizedString.vpnConnectionActive
    public var message: String? = LocalizedString.logOutWarning
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    
    public init(confirmHandler: @escaping () -> Void) {
        actions.append(AlertAction(title: LocalizedString.continue, style: .confirmative, handler: confirmHandler))
        actions.append(AlertAction(title: LocalizedString.cancel, style: .cancel, handler: nil))
    }
}

public class LogoutWarningLongAlert: LogoutWarningAlert {
    override public init(confirmHandler: @escaping () -> Void) {
        super.init(confirmHandler: confirmHandler)
        message = LocalizedString.logOutWarningLong
    }
}

public class BugReportSentAlert: SystemAlert {
    public var title: String? = ""
    public var message: String? = LocalizedString.reportSuccess
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    
    public init(confirmHandler: @escaping () -> Void) {
        actions.append(AlertAction(title: LocalizedString.ok, style: .confirmative, handler: confirmHandler))
    }
}

public class UnknownErrortAlert: SystemAlert {
    public var title: String? = LocalizedString.errorUnknownTitle
    public var message: String?
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    
    public init(error: Error, confirmHandler: (() -> Void)?) {
        message = error.localizedDescription
        actions.append(AlertAction(title: LocalizedString.ok, style: .confirmative, handler: confirmHandler))
    }
}

public class UserVerificationAlert: SystemAlert {
    public var title: String?
    public var message: String?
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    
    public let error: Error
    
    public init(error: Error) {
        self.error = error
        #if os(macOS)
        self.message = error.localizedDescription
        #endif
    }
}

public class ReportBugAlert: SystemAlert {
    public var title: String? = LocalizedString.errorUnknownTitle
    public var message: String?
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    
    public init() {}
}

public class MITMAlert: SystemAlert {
    public enum MessageType {
        case api
        case vpn
    }
    
    public var title: String? = LocalizedString.errorMitmTitle
    public var message: String? = LocalizedString.errorMitmDescription
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    
    public init(messageType: MessageType = .api) {
        switch messageType {
        case .api:
            message = LocalizedString.errorMitmDescription
        case .vpn:
            message = LocalizedString.errorMitmVpnDescription
        }        
    }
}

public class UnreachableNetworkAlert: SystemAlert {
    public var title: String? = LocalizedString.warning
    public var message: String? = LocalizedString.neUnableToConnectToHost
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    
    public init(error: Error, troubleshoot: @escaping () -> Void) {
        message = error.localizedDescription
        actions.append(AlertAction(title: LocalizedString.cancel, style: .cancel, handler: nil))
        actions.append(AlertAction(title: LocalizedString.neTroubleshoot, style: .confirmative, handler: troubleshoot))
    }
}

public class ConnectionTroubleshootingAlert: SystemAlert {
    public var title: String? = LocalizedString.errorUnknownTitle
    public var message: String?
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    
    public init() {}
}

public class VpnServerOnMaintenanceAlert: SystemAlert {
    public var title: String? = LocalizedString.maintenanceOnServerDetectedTitle
    public var message: String? = LocalizedString.maintenanceOnServerDetectedDescription
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    
    public init() { }
}

public class ReconnectOnNetshieldChangeAlert: SystemAlert {
    public var title: String? = LocalizedString.reconnectionRequired
    public var message: String? = LocalizedString.netshieldAlertReconnectDescriptionOn
    public var actions = [AlertAction]()
    public let isError: Bool = false
    public var dismiss: (() -> Void)?
    
    public init(isOn: Bool, continueHandler: @escaping () -> Void, cancelHandler: (() -> Void)? = nil) {
        message = isOn ? LocalizedString.netshieldAlertReconnectDescriptionOn : LocalizedString.netshieldAlertReconnectDescriptionOff
        actions.append(AlertAction(title: LocalizedString.continue, style: .confirmative, handler: continueHandler))
        actions.append(AlertAction(title: LocalizedString.cancel, style: .cancel, handler: cancelHandler))
    }
}

public class NetShieldRequiresUpgradeAlert: SystemAlert {
    public var title: String? = LocalizedString.upgradeRequired
    public var message: String? = LocalizedString.netshieldAlertUpgradeDescription + "\n\n" + LocalizedString.getPlusForFeature
    public var actions = [AlertAction]()
    public let isError: Bool = false
    public var dismiss: (() -> Void)?
    
    public init(continueHandler: @escaping () -> Void, cancelHandler: (() -> Void)? = nil) {
        actions.append(AlertAction(title: LocalizedString.upgrade, style: .confirmative, handler: continueHandler))
        actions.append(AlertAction(title: LocalizedString.cancel, style: .cancel, handler: cancelHandler))
    }
}

public class SysexEnabledAlert: SystemAlert {
    public var title: String? = LocalizedString.sysexEnabledTitle
    public var message: String? = LocalizedString.sysexEnabledDescription
    public var actions = [AlertAction]()
    public let isError: Bool = false
    public var dismiss: (() -> Void)?
    
    public init() {
        actions.append(AlertAction(title: LocalizedString.ok, style: .confirmative, handler: nil))
    }
}

public class SysexInstallingErrorAlert: SystemAlert {
    public var title: String? = LocalizedString.sysexCannotEnable
    public var message: String? = LocalizedString.sysexErrorDescription
    public var actions = [AlertAction]()
    public let isError: Bool = false
    public var dismiss: (() -> Void)?
    
    public init() {
        actions.append(AlertAction(title: LocalizedString.ok, style: .cancel, handler: nil))
    }
}

public class SystemExtensionTourAlert: SystemAlert {
    public var title: String?
    public var message: String?
    public var actions = [AlertAction]()
    public let isError: Bool = false
    public var dismiss: (() -> Void)?
    public var continueHandler: () -> Void
    public var cancelHandler: () -> Void
    public var extensionsCount: Int
    
    public init(extensionsCount: Int, continueHandler: @escaping () -> Void, cancelHandler: @escaping() -> Void) {
        self.extensionsCount = extensionsCount
        self.continueHandler = continueHandler
        self.cancelHandler = cancelHandler
    }
}

public class VPNAuthCertificateRefreshErrorAlert: SystemAlert {
    public var title: String? = LocalizedString.vpnauthCertfailTitle
    public var message: String? = LocalizedString.vpnauthCertfailDescription
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?

    public init() { }
}

public class MaxSessionsAlert: UserAccountUpdateAlert {
    public var imageName: String? = "sessions_limit"
    public var displayFeatures: Bool = false
    public var reconnectionInfo: VpnReconnectInfo?
    public var title: String? = LocalizedString.maximumDeviceTitle
    public var message: String?
    public var actions: [AlertAction] = []
    public var isError: Bool = false
    public var dismiss: (() -> Void)?
    
    public init(accountPlan: AccountPlan) {
        switch accountPlan {
        case .free, .basic:
            message = LocalizedString.maximumDeviceDescription(LocalizedString.tierPlus, AccountPlan.plus.devicesCount)
        default:
            message = LocalizedString.maximumDeviceReachedDescription
        }
        
        actions.append(AlertAction(title: LocalizedString.upgrade, style: .confirmative, handler: nil))
        actions.append(AlertAction(title: LocalizedString.noThanks, style: .cancel, handler: nil))
    }
}

public class UserPlanDowngradedAlert: UserAccountUpdateAlert {
    public var imageName: String?
    public var displayFeatures: Bool = true
    public var reconnectionInfo: VpnReconnectInfo?
    public var title: String? = LocalizedString.subscriptionExpiredTitle
    public var message: String? = LocalizedString.subscriptionExpiredDescription
    public var actions: [AlertAction] = []
    public var isError: Bool = false
    public var dismiss: (() -> Void)?
    
    public init(accountUpdate: VpnDowngradeInfo, reconnectionInfo: VpnReconnectInfo?) {
        actions.append(AlertAction(title: LocalizedString.upgradeAgain, style: .confirmative, handler: nil))
        actions.append(AlertAction(title: LocalizedString.noThanks, style: .cancel, handler: nil))
        self.reconnectionInfo = reconnectionInfo
        if reconnectionInfo?.to != nil {
            message = LocalizedString.subscriptionExpiredReconnectionDescription
        }
    }
}

public class UserBecameDelinquentAlert: UserAccountUpdateAlert {
    public var imageName: String?
    public var displayFeatures: Bool = false
    public var reconnectionInfo: VpnReconnectInfo?
    public var title: String? = LocalizedString.delinquentTitle
    public var message: String? = LocalizedString.delinquentDescription
    public var actions: [AlertAction] = []
    public var isError: Bool = false
    public var dismiss: (() -> Void)?
    
    public init(reconnectionInfo: VpnReconnectInfo?) {
        actions.append(AlertAction(title: LocalizedString.updateBilling, style: .confirmative, handler: nil))
        actions.append(AlertAction(title: LocalizedString.noThanks, style: .cancel, handler: nil))
        self.reconnectionInfo = reconnectionInfo
        if reconnectionInfo?.to != nil {
            message = LocalizedString.delinquentReconnectionDescription
        }
    }
}

public class VpnServerErrorAlert: SystemAlert {
    public var title: String? = LocalizedString.localAgentServerErrorTitle
    public var message: String? = LocalizedString.localAgentServerErrorMessage
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?

    public init() { }
}

public class VpnServerSubscriptionErrorAlert: SystemAlert {
    public var title: String? = LocalizedString.localAgentPolicyViolationErrorTitle
    public var message: String? = LocalizedString.localAgentPolicyViolationErrorMessage
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?

    public init() { }
}

public class AnnouncmentOfferAlert: SystemAlert {
    public var title: String?
    public var message: String?
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    public let data: OfferPanel

    public init(data: OfferPanel) {
        self.data = data
    }
}

public class NewBrandAlert: SystemAlert {
    public var title: String?
    public var message: String?
    public var actions: [AlertAction] = []
    public var isError: Bool = false
    public var onReadMore: (() -> Void) = {
        SafariService().open(url: CoreAppConstants.ProtonVpnLinks.updatedProton)
    }
    public var dismiss: (() -> Void)?

    public init() { }
}

public class DiscourageSecureCoreAlert: SystemAlert {
    public var title: String?
    public var message: String?
    public var actions: [AlertAction] = []
    public var isError: Bool = false
    public var onDontShowAgain: ((Bool) -> Void)?
    public var onActivate: (() -> Void)?
    public var onLearnMore: (() -> Void) = {
        SafariService().open(url: CoreAppConstants.ProtonVpnLinks.learnMore)
    }
    public var dismiss: (() -> Void)?

    public init() { }
}

public class UpsellAlert: SystemAlert {
    public var title: String?
    public var message: String?
    public var actions = [AlertAction]()
    public let isError = false
    public var dismiss: (() -> Void)?
    public func learnMore() { }
    public func upgradeAction() {
        SafariService().open(url: CoreAppConstants.ProtonVpnLinks.accountDashboard)
    }

    public init() { }

}

public class AllCountriesUpsellAlert: UpsellAlert { }

public class NetShieldUpsellAlert: UpsellAlert { }

public class SecureCoreUpsellAlert: UpsellAlert { }

public class SafeModeUpsellAlert: UpsellAlert {
    override public func learnMore() {
        SafariService().open(url: CoreAppConstants.ProtonVpnLinks.safeMode)
    }
}

public class ModerateNATUpsellAlert: UpsellAlert {
    override public func learnMore() {
        SafariService().open(url: CoreAppConstants.ProtonVpnLinks.moderateNAT)
    }
}

public class SubuserWithoutConnectionsAlert: SystemAlert {
    public var title: String?
    public var message: String?
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?

    public init() {
    }
}

public class TooManyCertificateRequestsAlert: SystemAlert {
    public var title: String? = LocalizedString.vpnauthTooManyCertsTitle
    public var message: String? = LocalizedString.vpnauthTooManyCertsDescription
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
}

public class WireguardKSOnCatalinaAlert: SystemAlert {
    public var title: String? = LocalizedString.wgksTitle
    public var message: String? = LocalizedString.wgksDescription
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?
    
    public init(killSwitchOffHandler: @escaping () -> Void, openVpnHandler: @escaping () -> Void) {
        actions.append(AlertAction(title: LocalizedString.wgksKsOff, style: .confirmative, handler: killSwitchOffHandler))
        actions.append(AlertAction(title: LocalizedString.wgksOvpn, style: .confirmative, handler: openVpnHandler))
    }
}

public class NEKSOnT2Alert: SystemAlert {
    public static let t2kbUrlString = "https://support.apple.com/en-us/HT208862"

    public var title: String? = LocalizedString.neksT2Title
    public var message: String? = LocalizedString.neksT2Description
    public var actions: [AlertAction] = []
    public var isError: Bool = false
    public var dismiss: (() -> Void)?

    public let link = LocalizedString.neksT2Hyperlink
    public let killSwitchOffAction: AlertAction
    public let connectAnywayAction: AlertAction

    public init(killSwitchOffHandler: @escaping () -> Void, connectAnywayHandler: @escaping () -> Void) {
        self.killSwitchOffAction = AlertAction(title: LocalizedString.wgksKsOff, style: .confirmative, handler: killSwitchOffHandler)
        self.connectAnywayAction = AlertAction(title: LocalizedString.neksT2Connect, style: .destructive, handler: connectAnywayHandler)
    }
}

public class ProtonUnreachableAlert: SystemAlert {
    public var title: String?
    public var message: String? = LocalizedString.protonWebsiteUnreachable
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?

    public init() {
    }
}

public class LocalAgentSystemErrorAlert: SystemAlert {
    public var title: String?
    public var message: String?
    public var actions = [AlertAction]()
    public let isError: Bool = true
    public var dismiss: (() -> Void)?

    init(error: LocalAgentErrorSystemError) {
        switch error {
        case .splitTcp:
            title = LocalizedString.vpnAcceleratorTitle
            message = LocalizedString.vpnFeatureCannotBeSetError(LocalizedString.vpnAcceleratorTitle)
        case .netshield:
            title = LocalizedString.netshieldTitle
            message = LocalizedString.vpnFeatureCannotBeSetError(LocalizedString.netshieldTitle)
        case .nonRandomizedNat:
            title = LocalizedString.moderateNatTitle
            message = LocalizedString.vpnFeatureCannotBeSetError(LocalizedString.moderateNatTitle)
        case .safeMode:
            title = LocalizedString.nonStandardPortsTitle
            message = LocalizedString.vpnFeatureCannotBeSetError(LocalizedString.nonStandardPortsTitle)
        }
    }
}
