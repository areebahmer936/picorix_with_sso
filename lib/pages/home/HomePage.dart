import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:picorix/services/adHelper/adHelper.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    if (!kIsWeb) {
      ref.read(admobProvider.notifier).loadBannerAd();
      ref.read(admobProvider.notifier).loadInterstitialAd();
      ref.read(admobProvider.notifier).loadRewardedAd();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("holyshit");
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            !kIsWeb
                ? ref.watch(admobProvider).bannerAd == null
                    ? const SizedBox()
                    : Container(
                        color: Colors.white,
                        height: ref
                            .watch(admobProvider)
                            .bannerAd!
                            .size
                            .height
                            .toDouble(),
                        width: ref
                            .watch(admobProvider)
                            .bannerAd!
                            .size
                            .width
                            .toDouble(),
                        child: AdWidget(ad: ref.watch(admobProvider).bannerAd!),
                      )
                : SizedBox(),
            Center(child: Text("hello home")),
            Hero(
              tag: "buttonTag",
              child: SizedBox(
                width: 200,
                height: 100,
                child: MaterialButton(
                    color: Colors.blue,
                    onPressed: () {
                      //ref.read(admobProvider.notifier).loadBannerAd();
                      // Navigator.pushNamed(context, '/login');
                    }),
              ),
            ),

            // -------------------------------------
            !kIsWeb
                ? ElevatedButton(
                    onPressed: () {
                      //ref.read(admobProvider).interstitialAd!.show();
                    },
                    child: const Text('Interstitial Ad'),
                  )
                : SizedBox(),
            !kIsWeb
                ? ElevatedButton(
                    onPressed: ref.watch(admobProvider).rewardedAd == null
                        ? () {}
                        : () {
                            ref
                                .read(admobProvider)
                                .rewardedAd!
                                .setImmersiveMode(true);
                            ref.read(admobProvider).rewardedAd!.show(
                              onUserEarnedReward: (ad, reward) {
                                print(reward);
                              },
                            );
                            // .whenComplete(() async {
                            //   // Navigator.of(context).push(MaterialPageRoute(
                            //   //   builder: (context) => const rewardedAdView(),
                            //   // ));
                            // });
                          },
                    child: const Text('Rewarded Ad'),
                  )
                : SizedBox(),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/wordsearch');
                },
                child: Text("word search"))
          ],
        ),
      ),
    );
  }
}
