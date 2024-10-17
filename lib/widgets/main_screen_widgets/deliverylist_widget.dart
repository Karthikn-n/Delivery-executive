import 'dart:io';

import 'package:app_5/providers/api_provider.dart';
import 'package:app_5/screens/sub_screen/map_route.dart';
import 'package:app_5/widgets/common_widgets/button.dart';
import 'package:app_5/widgets/common_widgets/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/delivery_products_model.dart';

class DeliverylistWidget extends StatefulWidget {
  // final List<DeliveryProducts> deliveryProducts;
  // final List<OrderedProductsModel> additionalOrderedProducts;
  const DeliverylistWidget({super.key,});
  @override
  State<DeliverylistWidget> createState() => _DeliverylistWidgetState();
}

class _DeliverylistWidgetState extends State<DeliverylistWidget> {
  List<String> productsType = ['Subscribed', "Ordered"];
  String selectedProductType = 'Subscribed';
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Consumer<ApiProvider>(
      builder: (context, provider, child) {
        return FutureBuilder(
          future: provider.deliverListAPi(),
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
            }else if(snapshot.hasError){
                return deliveryList(context, size);
            } else if (snapshot.error is HttpException) {
              // Custom handling for empty or failed data
              return const Center(
                child: TextWidget(
                  text: "No Delivery list available.",
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              );
            } else if(snapshot.hasData) {
              return deliveryList(context, size);
            } else{
              return deliveryList(context, size);
            }
          },
        );
    
      }
    );
  }

  Widget deliveryList(BuildContext context, Size size){
    return Consumer<ApiProvider>(
      builder: (context, provider, child) {
        return CupertinoScrollbar(
          controller: _scrollController,
          child: RefreshIndicator(
            onRefresh: () async => await provider.deliverListAPi() ,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: provider.deliveryProductsList.length,
              // itemCount: 6,
              itemBuilder: (context, index) {
              DeliveryProducts product = provider.deliveryProductsList[index];
              return Column(
                  children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300)
                          ),
                          padding: const EdgeInsets.all(10),
                          // margin: const EdgeInsets.only(top: 10),
                          // height: 240,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: size.width * 0.55,
                                      child: TextWidget(
                                        text: '${product.firstName} ${product.lastName}', 
                                        fontSize: 18, 
                                        textOverflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                      )
                                    ),
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
                                      text: product.mobileNo, 
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
                                      text: product.email, 
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
                                      text: '''${product.flatNo}, ${product.floor}, ${product.address}, ${product.landmark}, ${product.location}, ${product.region}''',   
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400, 
                                      ),
                                    ),
                                  ],
                                ),
                                // const SizedBox(height: 5,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: size.width * 0.2,
                                      child: const TextWidget(
                                        text: 'Products:', 
                                        fontSize: 15, 
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3.0),
                                      child: DropdownButton(
                                        underline: Container(),
                                        value: selectedProductType,
                                        dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                                        elevation: 1,
                                        items: productsType.map((type) {
                                          return DropdownMenuItem(
                                            value: type,
                                            child: TextWidget(
                                              text: type, 
                                              fontWeight: FontWeight.w500, 
                                              fontSize: 13,
                                              fontColor: Theme.of(context).primaryColor,
                                            )
                                          );
                                        },).toList(), 
                                        onChanged: (value) {
                                          setState(() {
                                            selectedProductType = value!;
                                          });
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                selectedProductType == "Ordered"
                                ? product.orderProducts.isEmpty
                                  ? const Center(
                                    child: TextWidget(text: 'No Ordered Products found', fontWeight: FontWeight.w500, fontSize: 16),
                                  )
                                  :  SizedBox(
                                        height: size.height * 0.15,
                                        child: ListView.builder(
                                          itemCount: product.orderProducts.length,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, orderProductIndex) {
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 8),
                                              child: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade200,
                                                  borderRadius: BorderRadius.circular(10)
                                                ),
                                                child: Center(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      SizedBox(
                                                        width: size.width * 0.4,
                                                        child: TextWidget(
                                                          text: product.orderProducts[orderProductIndex].productName, 
                                                          fontWeight: FontWeight.w600, 
                                                          maxLines: 2,
                                                          textOverflow: TextOverflow.ellipsis,
                                                          fontSize: 14
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5,),
                                                      Row(
                                                        children: [
                                                          const TextWidget(text: 'Quantity: ', fontWeight: FontWeight.w600, fontSize: 14),
                                                          TextWidget(text: '${product.orderProducts[orderProductIndex].quantity.toString()} x ${product.orderProducts[orderProductIndex].quantity}', fontWeight: FontWeight.w400, fontSize: 13),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 5,),
                                                      Row(
                                                        children: [
                                                          const TextWidget(text: 'Price: ', fontWeight: FontWeight.w600, fontSize: 14),
                                                          TextWidget(text: '₹${product.orderProducts[orderProductIndex].price}', fontWeight: FontWeight.w400, fontSize: 13),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                : product.products.isEmpty
                                  ? const TextWidget(text: 'No Subscribed Products found', fontWeight: FontWeight.w500, fontSize: 16)
                                  : SizedBox(
                                      height: size.height * 0.18,
                                      child: ListView.builder(
                                        itemCount: product.products.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, subProductIndex) {
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius: BorderRadius.circular(10)
                                              ),
                                              child: Center(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: size.width * 0.4,
                                                      child: TextWidget(
                                                        text: product.products [subProductIndex].productName, 
                                                        fontWeight: FontWeight.w600, 
                                                        maxLines: 2,
                                                        textOverflow: TextOverflow.ellipsis,
                                                        fontSize: 14
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5,),
                                                    Row(
                                                      children: [
                                                        const TextWidget(text: 'Morning: ', fontWeight: FontWeight.w600, fontSize: 14),
                                                        TextWidget(text: '${product.products[subProductIndex].mrngQty.toString()} x ${product.products[subProductIndex].quantity}', fontWeight: FontWeight.w400, fontSize: 13),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5,),
                                                    Row(
                                                      children: [
                                                        const TextWidget(text: 'Evening: ', fontWeight: FontWeight.w600, fontSize: 14),
                                                        TextWidget(text: '${product.products[subProductIndex].evgQty.toString()} x ${product.products[subProductIndex].quantity}', fontWeight: FontWeight.w400, fontSize: 13),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5,),
                                                    Row(
                                                      children: [
                                                        const TextWidget(text: 'Price: ', fontWeight: FontWeight.w600, fontSize: 14),
                                                        TextWidget(text: '₹${product.products[subProductIndex].price}', fontWeight: FontWeight.w400, fontSize: 13),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                const SizedBox(height: 12,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Call button
                                    ButtonWidget(
                                      width: size.width * 0.64,
                                      title: 'Call Customer', 
                                      onPressed: () async {
                                        final Uri url = Uri(
                                          scheme: 'tel',
                                          path: product.mobileNo
                                        );
                                        await launchUrl(url);
                                      },
                                    ),
                                    // Map Location Button
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => MapScreen(
                                              productDetails: product, 
                                              customerId: product.customerId,
                                              addressId: product.addressId,
                                              address: '${product.flatNo}, ${product.floor} ${product.address},${product.landmark},${product.location}, ${product.region}',
                                            ),
                                          )
                                        );
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.only(left: 10, right: 10),
                                        child:  Icon(CupertinoIcons.map, size: 26, color: Color(0xFF60B47B),),
                                      ),
                                    ),
                                  ],
                                ),
                            
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]
                  );
                },
            ),
          ),
        );
      },
    );
  }
}
