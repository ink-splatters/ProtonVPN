//
//  Created on 04.01.23.
//
//  Copyright (c) 2023 Proton AG
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
import LegacyCommon

class SecureCoreWarningViewModel {
    let sessionService: SessionService

    init(sessionService: SessionService) {
        self.sessionService = sessionService
    }

    func upgradeButtonPressed() async {
        let url = await sessionService.getPlanSession(mode: .upgrade)
        SafariService.openLink(url: url)
    }

    func learnMoreButtonPressed() {
        SafariService().open(url: CoreAppConstants.ProtonVpnLinks.learnMore)
    }
}
