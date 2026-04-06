package com.lovetok.sovereign

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import android.view.LayoutInflater
import android.widget.TextView
import android.widget.Button
import android.widget.ImageView
import com.google.android.gms.ads.nativead.MediaView

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // A_111: Register Sovereign Native Ad Factory for V15 Logic
        val factory = SovereignNativeAdFactory(layoutInflater)
        // Fixed: Correct package path for V15 Registration
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "adFactoryExample", factory)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "adFactoryExample")
    }
}

class SovereignNativeAdFactory(private val layoutInflater: LayoutInflater) : NativeAdFactory {
    override fun createNativeAd(nativeAd: NativeAd, customOptions: MutableMap<String, Any>?): NativeAdView {
        val adView = layoutInflater.inflate(R.layout.native_ad_layout, null) as NativeAdView

        // Map Headline
        adView.headlineView = adView.findViewById(R.id.ad_headline)
        (adView.headlineView as TextView).text = nativeAd.headline

        // Map Body
        adView.bodyView = adView.findViewById(R.id.ad_body)
        if (nativeAd.body == null) {
            adView.bodyView?.visibility = android.view.View.GONE
        } else {
            adView.bodyView?.visibility = android.view.View.VISIBLE
            (adView.bodyView as TextView).text = nativeAd.body
        }

        // Map Call to Action
        adView.callToActionView = adView.findViewById(R.id.ad_call_to_action)
        if (nativeAd.callToAction == null) {
            adView.callToActionView?.visibility = android.view.View.INVISIBLE
        } else {
            adView.callToActionView?.visibility = android.view.View.VISIBLE
            (adView.callToActionView as Button).text = nativeAd.callToAction
        }

        // Map Icon
        adView.iconView = adView.findViewById(R.id.ad_app_icon)
        if (nativeAd.icon == null) {
            adView.iconView?.visibility = android.view.View.GONE
        } else {
            (adView.iconView as ImageView).setImageDrawable(nativeAd.icon?.drawable)
            adView.iconView?.visibility = android.view.View.VISIBLE
        }

        // Map Advertiser
        adView.advertiserView = adView.findViewById(R.id.ad_advertiser)
        if (nativeAd.advertiser == null) {
            adView.advertiserView?.visibility = android.view.View.GONE
        } else {
            (adView.advertiserView as TextView).text = nativeAd.advertiser
            adView.advertiserView?.visibility = android.view.View.VISIBLE
        }

        // Map Media
        adView.mediaView = adView.findViewById<MediaView>(R.id.ad_media)
        if (nativeAd.mediaContent != null) {
            adView.mediaView?.setMediaContent(nativeAd.mediaContent!!)
        }

        adView.setNativeAd(nativeAd)
        return adView
    }
}
