//
//  PhantomConnectViewModel.swift
//  PhantomConnect
//
//  Created by Eric McGary on 6/28/22.
//

import Foundation
import Solana
import SwiftUI
import UIKit

@Observable
public class PhantomConnectViewModel {
    
    // ============================================================
    // === Public API =============================================
    // ============================================================
    
    // MARK: - Public API
    
    // MARK: Public Properties
   
    public var getLinkingKeypair: (() -> BoxedKeypair?)? = nil
    public var setLinkingKeypair: ((BoxedKeypair?) -> Void)? = nil
    
    // default storage of keypair in memory
    private var _linkingKeypair: BoxedKeypair? = nil
    public var linkingKeypair : BoxedKeypair? {
        get { getLinkingKeypair?() ?? _linkingKeypair }
        set {
            if let setLinkingKeypair {
                setLinkingKeypair(newValue)
            } else {
                _linkingKeypair = newValue
            }
        }
    }
    
    /// Linking key pair public key used for shared secret. This property should only be counted on being present during the app session where connection was made, unless manually set.
    public var encryptionPublicKey: PublicKey {
        return linkingKeypair?.publicKey ?? PublicKey(bytes: PublicKey.NULL_PUBLICKEY_BYTES)!
    }
    
    // MARK: Public Methods
    
    /// Constructor
    /// - Parameter phantomConnectService: Dependency injected service
    public init(phantomConnectService: PhantomConnectService? = PhantomConnectService()) {
        self.phantomConnectService = phantomConnectService!
    }
    
    /// Constructor
    /// - Parameter phantomConnectService: Dependency injected service
    public init(
        phantomConnectService: PhantomConnectService? = PhantomConnectService(),
        getLinkingKeypair: @escaping () -> BoxedKeypair?,
        setLinkingKeypair: @escaping (BoxedKeypair?) -> Void
    ) {
        self.phantomConnectService = phantomConnectService!
        self.getLinkingKeypair = getLinkingKeypair
        self.setLinkingKeypair = setLinkingKeypair
    }
    
    /// This method kicks the app over to the  phantom app via a universal link created in the `PhantomConnectService`
    public func connectWallet() throws {
        
        if linkingKeypair == nil {
            linkingKeypair = try SolanaUtils.generateBoxedKeypair()
        }
    
        let url = try phantomConnectService.connect(
            publicKey: linkingKeypair!.publicKey.data
        )
        
        UIApplication.shared.open(url)
        
    }
    
    /// Generates url for disconnecting phantom wallet
    /// - Parameters:
    ///   - dappEncryptionKey: The public key generated for original connection
    ///   - phantomEncryptionKey: Public key returned from phantom during initial connection
    ///   - session: Session returned from original connection with phantom
    ///   - dappSecretKey: 32 Byte private key generated for initial phatom wallet connection
    public func disconnectWallet(
        dappEncryptionKey: PublicKey?,
        phantomEncryptionKey: PublicKey?,
        session: String?,
        dappSecretKey: Data?
    ) throws {
        
        let (encryptedPayload, nonce) = try PhantomUtils.encryptPayload(
            payload: [
                "session": session ?? ""
            ],
            phantomEncryptionPublicKey: phantomEncryptionKey,
            dappSecretKey: dappSecretKey
        )
        
        let url = try phantomConnectService.disconnect(
            encryptionPublicKey: dappEncryptionKey,
            nonce: nonce,
            payload: encryptedPayload
        )
        
        UIApplication.shared.open(url)
        
    }
    
    /// Creates url for sending and signing a serialized solana transaction with the phantom app
    /// - Parameters:
    ///   - serializedTransaction: Serialized solana transaction
    ///   - dappEncryptionKey: The public key generated for original connection
    ///   - phantomEncryptionKey: Public key returned from phantom during initial connection
    ///   - session: Session returned from original connection with phantom
    ///   - dappSecretKey: 32 Byte private key generated for initial phatom wallet connection
    public func sendAndSignTransaction(
        serializedTransaction: String?,
        dappEncryptionKey: PublicKey?,
        phantomEncryptionKey: PublicKey?,
        session: String?,
        dappSecretKey: Data?
    ) throws {
        
        guard let serializedTransaction = serializedTransaction else {
            throw PhantomConnectError.invalidSerializedTransaction
        }
        
        let (encryptedPayload, nonce) = try PhantomUtils.encryptPayload(
            payload: [
                "session": session ?? "",
                "transaction": serializedTransaction
            ],
            phantomEncryptionPublicKey: phantomEncryptionKey,
            dappSecretKey: dappSecretKey
        )
        
        let url = try phantomConnectService.signAndSendTransaction(
            encryptionPublicKey: dappEncryptionKey,
            nonce: nonce,
            payload: encryptedPayload
        )
        
        UIApplication.shared.open(url)
        
    }
    
    // ============================================================
    // === Private API ============================================
    // ============================================================
    
    // MARK: - Private API
    
    // MARK: Private Properties
    
    private let phantomConnectService: PhantomConnectService
    
}
