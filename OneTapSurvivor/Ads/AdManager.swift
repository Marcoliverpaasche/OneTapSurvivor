import UIKit
import AppLovinSDK

enum AdRewardType {
    case extraLife
    case doubleScore
    case dailyBonus
}

/// AppLovin MAX Rewarded Ads. Debug simuliert, Release zeigt echte Ads.
final class AdManager: NSObject {

    static let shared = AdManager()

    private var rewardedAd: MARewardedAd?
    private var rewardCallback: ((Bool) -> Void)?
    private var didEarnReward = false
    private var retryAttempt = 0.0
    private var isSDKReady = false

    private override init() {
        super.init()
    }

    private var hasPlaceholderKeys: Bool { Constants.hasValidAdKeys == false }

    func initializeSDK() {
        #if DEBUG
        print("[AdManager] Debug-Modus: Werbung wird simuliert")
        return
        #else
        guard hasPlaceholderKeys == false else {
            print("[AdManager] SDK-Keys fehlen — Ads werden übersprungen")
            return
        }

        // GDPR-Einwilligung: AppLovins eingebauter Terms-&-Privacy-Flow (Google UMP).
        // Diese Settings MÜSSEN vor initialize(...) gesetzt werden. In GDPR-Regionen
        // zeigt MAX dann automatisch den UMP-Consent-Dialog und steuert danach den
        // ATT-Prompt — deshalb wird ATT nicht mehr manuell angefragt.
        let settings = ALSdk.shared().settings
        settings.userIdentifier = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        settings.termsAndPrivacyPolicyFlowSettings.isEnabled = true
        if let privacyURL = URL(string: Constants.privacyPolicyURL) {
            settings.termsAndPrivacyPolicyFlowSettings.privacyPolicyURL = privacyURL
        }
        if Constants.termsOfServiceURL.isEmpty == false,
           let termsURL = URL(string: Constants.termsOfServiceURL) {
            settings.termsAndPrivacyPolicyFlowSettings.termsOfServiceURL = termsURL
        }
        settings.termsAndPrivacyPolicyFlowSettings.shouldShowTermsAndPrivacyPolicyAlertInGDPR = true

        let initConfig = ALSdkInitializationConfiguration(sdkKey: Constants.maxSdkKey) { builder in
            builder.mediationProvider = ALMediationProviderMAX
        }

        ALSdk.shared().initialize(with: initConfig) { [weak self] _ in
            DispatchQueue.main.async {
                self?.isSDKReady = true
                self?.loadRewardedAd()
                print("[AdManager] AppLovin MAX bereit")
            }
        }
        #endif
    }

    func showRewardedAd(
        from viewController: UIViewController,
        placement: AdRewardType,
        completion: @escaping (Bool) -> Void
    ) {
        #if DEBUG
        simulateAd(from: viewController, placement: placement, completion: completion)
        #else
        rewardCallback = completion
        didEarnReward = false

        if let ad = rewardedAd, ad.isReady {
            ad.show()
        } else {
            // Ad-Fehler: Reward trotzdem geben, Spieler nicht bestrafen.
            loadRewardedAd()
            DispatchQueue.main.async {
                completion(true)
            }
        }
        #endif
    }

    // MARK: - Consent / Datenschutz

    /// Öffnet den CMP-Dialog erneut, damit Nutzer in GDPR-Regionen ihre
    /// Einwilligung nachträglich ändern können ("Datenschutz verwalten").
    /// Setzt die bestehende Einwilligung zurück und zeigt den UMP-Dialog neu.
    func showPrivacySettings(completion: (() -> Void)? = nil) {
        #if DEBUG
        completion?()
        #else
        ALSdk.shared().cmpService.showCMPForExistingUser { error in
            if let error {
                print("[AdManager] CMP-Fehler: \(error.message)")
            }
            DispatchQueue.main.async { completion?() }
        }
        #endif
    }

    // MARK: - Load

    private func loadRewardedAd() {
        #if DEBUG
        return
        #else
        if rewardedAd == nil {
            let ad = MARewardedAd.shared(withAdUnitIdentifier: Constants.maxRewardedAdUnitID)
            ad.delegate = self
            rewardedAd = ad
        }
        rewardedAd?.load()
        #endif
    }

    // MARK: - Debug Simulation

    #if DEBUG
    private func simulateAd(
        from viewController: UIViewController,
        placement: AdRewardType,
        completion: @escaping (Bool) -> Void
    ) {
        var didFinish = false
        let finish: (Bool) -> Void = { success in
            guard didFinish == false else { return }
            didFinish = true
            DispatchQueue.main.async {
                completion(success)
            }
        }

        let title: String
        switch placement {
        case .extraLife: title = "📺 [DEBUG] +1 Leben"
        case .doubleScore: title = "📺 [DEBUG] Score ×2"
        case .dailyBonus: title = "📺 [DEBUG] Täglicher Bonus"
        }

        let alert = UIAlertController(
            title: title,
            message: "Simulierte Rewarded Ad — schließt in 5s",
            preferredStyle: .alert
        )

        var seconds = 5
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            seconds -= 1
            if seconds <= 0 {
                timer.invalidate()
                alert.dismiss(animated: true) {
                    finish(true)
                }
            } else {
                alert.message = "Simulierte Rewarded Ad — schließt in \(seconds)s"
            }
        }

        alert.addAction(UIAlertAction(title: "Überspringen (Debug)", style: .cancel) { _ in
            timer.invalidate()
            finish(true)
        })

        viewController.present(alert, animated: true)
        RunLoop.main.add(timer, forMode: .common)
    }
    #endif
}

extension AdManager: MARewardedAdDelegate {

    func didLoad(_ ad: MAAd) {
        retryAttempt = 0
        print("[AdManager] Rewarded Ad geladen")
    }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        print("[AdManager] Load-Fehler: \(error.message)")
        retryAttempt += 1
        let delay = pow(2.0, min(6.0, retryAttempt))
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.loadRewardedAd()
        }
    }

    func didDisplay(_ ad: MAAd) {
        print("[AdManager] Ad angezeigt")
    }

    func didClick(_ ad: MAAd) {}

    func didHide(_ ad: MAAd) {
        let earned = didEarnReward
        didEarnReward = false
        let callback = rewardCallback
        rewardCallback = nil
        loadRewardedAd()
        DispatchQueue.main.async {
            callback?(earned)
        }
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        print("[AdManager] Display-Fehler: \(error.message)")
        let callback = rewardCallback
        rewardCallback = nil
        loadRewardedAd()
        // Bei Ad-Fehler: Reward trotzdem geben.
        DispatchQueue.main.async {
            callback?(true)
        }
    }

    func didRewardUser(for ad: MAAd, with reward: MAReward) {
        didEarnReward = true
        print("[AdManager] Reward: \(reward.amount) \(reward.label)")
    }
}
