//
//  PhantomConnectViewModel.swift
//  Rhove
//
//  Created by Eric McGary on 6/21/22.
//

import Foundation
import Solana

@available(iOS 13.0, *)
public class PhantomConnectViewModel: ObservableObject {
    
    // ============================================================
    // === Public API =============================================
    // ============================================================
    
    // MARK: Public Properties
    
    /// <#Description#>
    @Published public var pendingDeeplink: PhantomDeeplink?
    
    /// <#Description#>
    public var linkingKeypair: BoxedKeypair?
    
    /// <#Description#>
    public var encryptionPublicKey: PublicKey {
        return linkingKeypair?.publicKey ?? PublicKey(bytes: PublicKey.NULL_PUBLICKEY_BYTES)!
    }
    
    // MARK: Public Methods
    
    /// Constructor
    /// - Parameter phantomConnectService: <#phantomConnectService description#>
    init(phantomConnectService: PhantomConnectService) {
        self.phantomConnectService = phantomConnectService
    }
    
    /// This method kicks the app over to the  phantom app via a universal link created in the `PhantomConnectService`
    public func connectWallet() {
        
        linkingKeypair = try? SolanaUtils.generateBoxedKeypair()
    
        try? phantomConnectService.connect(
            publicKey: linkingKeypair?.publicKey.data ?? Data()
        )
        
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - dappEncryptionKey: <#dappEncryptionKey description#>
    ///   - phantomEncryptionKey: <#phantomEncryptionKey description#>
    ///   - session: <#session description#>
    ///   - dappSecretKey: <#dappSecretKey description#>
    public func disconnectWallet(
        dappEncryptionKey: PublicKey?,
        phantomEncryptionKey: PublicKey?,
        session: String?,
        dappSecretKey: Data?
    ) throws {
        
        /*
         
         const payload = {
               session,
             };
             const [nonce, encryptedPayload] = encryptPayload(payload, sharedSecret);

             const params = new URLSearchParams({
               dapp_encryption_public_key: bs58.encode(dappKeyPair.publicKey),
               nonce: bs58.encode(nonce),
               redirect_link: onDisconnectRedirectLink,
               payload: bs58.encode(encryptedPayload),
             });

             const url = buildUrl("disconnect", params);
             Linking.openURL(url);
         
         */
        
        let (encryptedPayload, nonce) = try PhantomUtils.encryptPayload(
            payload: [
                "session": session ?? ""
            ],
            phantomEncryptionPublicKey: phantomEncryptionKey,
            dappSecretKey: dappSecretKey
        )
        
        try phantomConnectService.disconnect(
            encryptionPublicKey: dappEncryptionKey,
            nonce: nonce,
            payload: encryptedPayload
        )
      
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - serializedTransaction: <#serializedTransaction description#>
    ///   - dappEncryptionKey: <#dappEncryptionKey description#>
    ///   - phantomEncryptionKey: <#phantomEncryptionKey description#>
    ///   - session: <#session description#>
    ///   - dappSecretKey: <#dappSecretKey description#>
    public func sendAndSignTransaction(
        serializedTransaction: String?,
        dappEncryptionKey: PublicKey?,
        phantomEncryptionKey: PublicKey?,
        session: String?,
        dappSecretKey: Data?

    ) throws {
        
        /*
         try phantomConnectViewModel.sendAndSignTransaction(
             serializedTransaction: newValue,
             dappEncryptionKey: viewModel.cryptoWallet?.dappEncryptionKey,
             phantomEncryptionKey: viewModel.cryptoWallet?.phantomEncryptionKey,
             session: viewModel.cryptoWallet?.session,
             dappSecretKey: viewModel.cryptoWallet?.secretKey?.base58DecodedData
         )
         */
        
        guard let serializedTransaction = serializedTransaction else {
            throw PhantomConnectError.serializationIssue
        }
        
        let (encryptedPayload, nonce) = try PhantomUtils.encryptPayload(
            payload: [
                "session": session ?? "",
                "transaction": serializedTransaction
            ],
            phantomEncryptionPublicKey: phantomEncryptionKey,
            dappSecretKey: dappSecretKey
        )
        
        try phantomConnectService.signAndSendTransaction(
            encryptionPublicKey: dappEncryptionKey,
            nonce: nonce,
            payload: encryptedPayload
        )
        
    }
    
    // ============================================================
    // === Private API ============================================
    // ============================================================
    
    // MARK: Private Properties
    
    private let phantomConnectService: PhantomConnectService
    
    // MARK: Private Methods
    
}
