import 'package:app_5/providers/api_provider.dart';
import 'package:app_5/screens/sub_screen/update_loction.dart';
import 'package:app_5/widgets/common_widgets/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/customer_address_model.dart';

class CustomerAddressWidget extends StatefulWidget {
  const CustomerAddressWidget({super.key,});

  @override
  State<CustomerAddressWidget> createState() => _CustomerAddressWidgetState();
}

class _CustomerAddressWidgetState extends State<CustomerAddressWidget> {
  final ScrollController _controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Consumer<ApiProvider>(
      builder: (context, provider, child) {
        return provider.addressList.isEmpty
        ? FutureBuilder(
            future: provider.customerAddressList(), 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  children: [
                    LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      color: Theme.of(context).primaryColor,
                    )
                  ],
                );
              }else if(!snapshot.hasData || snapshot.hasError){
                return const Center(
                  child: TextWidget(text: "No Customer list", fontWeight: FontWeight.w500, fontSize: 15),
                );
              }else{
                return addressList(size, context);
              }
            },
          )
        : addressList(size, context) ;
      },
    );
  }

  Widget addressList(Size size, BuildContext context){
    return Consumer<ApiProvider>(
      builder: (context, provider, child) {
        return CupertinoScrollbar(
          controller: _controller,
          child: ListView.builder(
            controller: _controller,
            itemCount: provider.addressList.length,
            itemBuilder: (context, index) {
              CustomerAddress address = provider.addressList[index];
              return Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10,),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300)
                    ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: size.width * 0.65,
                              child: TextWidget(
                                text: '${address.firstName} ${address.lastName}',
                                fontSize: 16,
                                fontWeight: FontWeight.w600                    
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => UpdateLocation(
                                      name: '${address.firstName} ${address.lastName}',
                                      customerId: address.customerId,
                                      addressId: address.addressId,
                                      ),
                                    ));
                                  },
                                  child: Icon(
                                    CupertinoIcons.map, 
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 15,),
                                GestureDetector(
                                  onTap: () async {
                                    final Uri url = Uri(
                                      scheme: 'tel',
                                      path: address.mobileNo
                                    );
                                    await launchUrl(url);
                                  },
                                  child: Icon(
                                    CupertinoIcons.phone,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          children: [
                            SizedBox(
                              width: size.width * 0.2,
                              child: const TextWidget(
                                text: 'Contact: ', 
                                fontSize: 15, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextWidget(
                              text: address.mobileNo, 
                              fontSize: 13, 
                              // textDecoration: TextDecoration.underline, 
                              fontWeight: FontWeight.w400, 
                              fontColor: const Color(0xFF60B47B), 
                            ),
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          children: [
                            SizedBox(
                              width: size.width * 0.2,
                              child: const TextWidget(
                                text: 'Email: ', 
                                fontSize: 15, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            TextWidget(
                              text: address.email, 
                              fontSize: 13, 
                              fontWeight: FontWeight.w400, 
                              fontColor: const Color(0xFF60B47B),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: size.width * 0.2,
                              child: const TextWidget(
                                text: 'Address: ', 
                                fontSize: 15, 
                                fontWeight: FontWeight.bold
                                ),
                            ),
                            Expanded(
                              child: TextWidget(
                              text: '''${address.flatNo}, ${address.floor}, ${address.address}, ${address.landmark}, ${address.location}, ${address.region}''',   
                              fontSize: 13,
                              fontWeight: FontWeight.w400, 
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ),
              );
            }, 
          ),
        );
      
      },
    );
  }

}
