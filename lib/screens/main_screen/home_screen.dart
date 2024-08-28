import 'package:app_5/helper/sharedPreference_helper.dart';
import 'package:app_5/providers/api_provider.dart';
import 'package:app_5/providers/connectivity_helper.dart';
import 'package:app_5/screens/main_screen/apply_leave_screen.dart';
import 'package:app_5/helper/navigation_helper.dart';
import 'package:app_5/widgets/common_widgets/button.dart';
import 'package:app_5/widgets/main_screen_widgets/sku_pickuplist_widget.dart';
import 'package:app_5/widgets/common_widgets/text_widget.dart';
import 'package:app_5/widgets/main_screen_widgets/customer_address_widget.dart';
import 'package:app_5/widgets/main_screen_widgets/deliverylist_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver{
  final SharedPreferences prefs = SharedpreferenceHelper.getInstance;
  late TabController _tabController;
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedTab = _tabController.index;
      });
    },);
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    final appConnectivity = Provider.of<ConnectivityService>(context);
    return !appConnectivity.isConnected
    ?  Scaffold(
        body: Center(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.25,),
              GestureDetector(
                onTap: () =>  print('${size.height} ${size.width}'),
                child: SizedBox(
                  height: size.height * 0.3,
                  width: size.width * 0.6,
                  child: Image.asset(
                    'assets/nointernet.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.005,),
              const TextWidget(text: 'OOPS!', fontWeight: FontWeight.w800, fontSize: 24),
              SizedBox(height: size.height * 0.005,),
              const TextWidget(text: 'NO INTERNET', fontWeight: FontWeight.w800, fontSize: 24),
              SizedBox(height: size.height * 0.01,),
              const TextWidget(text: 'Please check your internet connection.', fontWeight: FontWeight.w400, fontSize: 16),
              SizedBox(height: size.height * 0.02,),
              SizedBox(
              height: size.height * 0.06,
              width: size.width * 0.7,
              child: ButtonWidget(title: 'Try Again', onPressed: () => appConnectivity.isConnected ,)
              ),
              SizedBox(height: size.height * 0.22,),
            ],
          ),
        ),
      )
    : Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Executive', style:  TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),),
          centerTitle: true,
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.transparent,
          actions: [
            Consumer<ApiProvider>(
              builder: (context, provider, child) {
                return PopupMenuButton(
                  position: PopupMenuPosition.over,
                  color: Colors.white,
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: const TextWidget(text: 'Apply leave', fontWeight: FontWeight.w500, fontSize: 13),
                        onTap: () => Navigator.push(context, SideTransiion(screen: const ApplyLeaveScreen())), 
                      ),
                      PopupMenuItem(
                        child: const TextWidget(text: 'Logout', fontWeight: FontWeight.w500, fontSize: 13),
                        onTap: () {
                          provider.confirmLogout(context, size);
                          
                        }
                      ),
                    ];
                  },
                );
              }
            ),
          ]
        ),
        
      body: DefaultTabController(
        length: 3,
        child: CustomScrollView(
          slivers: [
           SliverAppBar(
              expandedHeight: size.height * 0.15,
              backgroundColor: Colors.white,
              centerTitle: true,
              floating: false,
              automaticallyImplyLeading: false,
              surfaceTintColor: Colors.transparent.withOpacity(0.0),
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Container(
                    alignment: Alignment.center,
                    width: size.width * 0.85,
                    decoration: BoxDecoration(
                      color: const Color(0xFF60B47B),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 15,),
                          SizedBox(
                            height: size.height * 0.12,
                            width: size.width * 0.24,
                            child: ClipOval(
                              child: Image.asset(
                                'assets/profile.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Consumer<ApiProvider>(
                                  builder: (context, provider, child) {
                                    return GestureDetector(
                                      onTap: () async {
                                        await provider.deliverListAPi();
                                      },
                                      child: TextWidget(text: prefs.getString("executiveName") ?? "No User Name", fontWeight: FontWeight.w500, fontSize: 20, fontColor: Colors.white,maxLines: 1, textOverflow: TextOverflow.ellipsis,));
                                  }
                                ),
                                const SizedBox(height: 3,),
                                TextWidget(text: prefs.getString("executiveEmail") ?? "nouser@gmail.com", fontWeight: FontWeight.w400, fontSize: 14, fontColor: Colors.white, maxLines: 1, textOverflow: TextOverflow.ellipsis,),
                                const SizedBox(height: 5,),
                                TextWidget(text: prefs.getString("executiveMobile") ?? "11111 11111", fontWeight: FontWeight.w400, fontSize: 13, fontColor: Colors.white,),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TabBar(
                      key: const PageStorageKey('tab'),
                      overlayColor: WidgetStatePropertyAll(Colors.transparent.withOpacity(0.0)),
                      controller: _tabController,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      isScrollable: true,
                      dividerColor: Colors.transparent.withOpacity(0.0),
                      indicatorColor: Colors.transparent.withOpacity(0.0),
                      tabAlignment: TabAlignment.start,
                      tabs: [
                        // SKU Pickuplist Tab
                        Tab(
                          height: size.height * 0.08,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                              color: _tabController.index == 0 ?  const Color(0xFF60B47B) : null
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const SizedBox(width: 10,),
                                SizedBox(
                                  width: 60,
                                  height: 80,
                                  child: Image.asset('assets/home1.png', fit: BoxFit.cover,),
                                ),
                                const SizedBox(width: 5,),
                                SizedBox(
                                  height: 40,
                                  child: VerticalDivider(
                                    color: _tabController.index == 0 ? Colors.white : Colors.black,
                                    thickness: 2,
                                  ),
                                ),
                                const SizedBox(width: 5,),
                                TextWidget(text: 'Pick-up list', fontWeight: FontWeight.w600, fontSize: 15, fontColor: _tabController.index == 0 ? Colors.white : Colors.black,),
                                const SizedBox(width: 10,),
                              ],
                            ),
                          ),
                        ),
                        // Delivery list Tab
                        Tab(
                          height: size.height * 0.08,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                              color: _tabController.index == 1 ?const Color(0xFF60B47B) : null
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const SizedBox(width: 10,),
                                SizedBox(
                                  width: 60,
                                  height: 80,
                                  child: Image.asset('assets/home2.png', fit: BoxFit.cover,),
                                ),
                                const SizedBox(width: 5,),
                                SizedBox(
                                  height: 40,
                                  child: VerticalDivider(
                                    color: _tabController.index == 1 ? Colors.white : Colors.black,
                                    thickness: 2,
                                  ),
                                ),
                                const SizedBox(width: 5,),
                                TextWidget(text: 'Delivery list', fontWeight: FontWeight.w600, fontSize: 15, fontColor: _tabController.index == 1 ? Colors.white : Colors.black,),
                                const SizedBox(width: 10,),
                              ],
                            ),
                          ),
                        ),
                        // Customer Update Locations Tap
                        Tab(
                          height: size.height * 0.08,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                              color: _tabController.index == 2 ? const Color(0xFF60B47B) : null
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const SizedBox(width: 10,),
                                SizedBox(
                                  width: 60,
                                  height: 80,
                                  child: Image.asset('assets/home3.png', fit: BoxFit.cover,),
                                ),
                                const SizedBox(width: 5,),
                                SizedBox(
                                  height: 40,
                                  child: VerticalDivider(
                                    color: _tabController.index == 2 ? Colors.white : Colors.black,
                                    thickness: 2,
                                  ),
                                ),
                                const SizedBox(width: 5,),
                                TextWidget(text: 'Update Location', fontWeight: FontWeight.w600, fontSize: 15, fontColor: _tabController.index == 2 ? Colors.white : Colors.black,),
                                const SizedBox(width: 10,),
                              ],
                            ),
                          ),
                        ),
                      ]
                    ),
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(
                    height:  size.height * 0.6,
                    child: TabBarView(
                      key: const PageStorageKey('tab'),
                      controller: _tabController,
                      children: [
                        // Pick up list Screen
                        SizedBox(
                          height: size.height * 0.4,
                          child: SkuPickuplistWidget(
                            key: const PageStorageKey('sku'),
                          ),
                        ),
                        // Delivery List Screen
                        const DeliverylistWidget(
                          key: PageStorageKey('delivery'),
                        ),
                        // Update Location Screen
                        const CustomerAddressWidget(key: PageStorageKey('address'),)
                      ]
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      )
    );
  }


 
  
 

  



}



