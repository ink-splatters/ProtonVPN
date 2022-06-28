//
//  ServerStorageMock.swift
//  ProtonVPN - Created on 19/07/2019.
//
//  Copyright (c) 2019 Proton Technologies AG
//
//  This file is part of ProtonVPN.
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
//

import vpncore

class ServerStorageArrayMock: ServerStorage {
    
    var contentChanged: Notification.Name = Notification.Name(rawValue: "ServerStorageArrayMock.contentChanged")
    
    private var servers: [ServerModel]
    
    public init(servers: [ServerModel]) {
        self.servers = servers
    }
    
    func fetch() -> [ServerModel] {
        return servers
    }
    
    func store(_ newServers: [ServerModel]) {
        self.servers = newServers
    }
    
    func update(continuousServerProperties: ContinuousServerPropertiesDictionary) {
        
    }

    func fetchAge() -> TimeInterval {
        1
    }
}
