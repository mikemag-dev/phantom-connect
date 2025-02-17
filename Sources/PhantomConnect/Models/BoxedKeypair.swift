//
//  BoxedKeypair.swift
//  PhantomConnect
//
//  Created by Eric McGary on 6/28/22.
//

import Foundation
import Solana

public struct BoxedKeypair: Codable {
    
    // ============================================================
    // === Public API =============================================
    // ============================================================
    
    // MARK: - Public Static API
    
    // MARK: Public Static Methods
    
    /// 32 byte public key
    public let publicKey: PublicKey
    
    /// 32 byte secret key
    public let secretKey: Data
    
    public init(publicKey: PublicKey, secretKey: Data) {
        self.publicKey = publicKey
        self.secretKey = secretKey
    }
    
}
