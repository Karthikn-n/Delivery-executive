import 'package:app_5/helper/sharedPreference_helper.dart';
import 'package:app_5/model/ordered_products_model.dart';
import 'package:app_5/model/products_model.dart';
import 'package:app_5/providers/api_provider.dart';
import 'package:app_5/providers/live_location_provider.dart';
import 'package:app_5/widgets/common_widgets/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/sku_products_list_model.dart';

class SkuPickuplistWidget extends StatelessWidget {
  SkuPickuplistWidget({super.key});
  final SharedPreferences prefs = SharedpreferenceHelper.getInstance;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Consumer<ApiProvider>(
      builder: (context, provider, child) {
        return provider.allProducts.isEmpty && provider.skuPickList.isEmpty && provider.orderedProducts.isEmpty
          ? FutureBuilder(
              future: provider.skuListAPI(), 
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
                    child: TextWidget(text: "No products in inventry ", fontWeight: FontWeight.w500, fontSize: 15),
                  );
                }else{
                  return skuPickupList(size);
                }
              },
            )
          : skuPickupList(size);
      },
    );
    
  }

  Widget skuPickupList(Size size){
    return Consumer2<ApiProvider, LiverLocationProvider>(
      builder: (context, provider, location, child) {
        return  Stack(
          alignment: Alignment.center,
          children: [
            CupertinoScrollbar(
              controller: _scrollController,
              child: RefreshIndicator(
                onRefresh: () async {
                  await provider.skuListAPI();
                  await location.connect();
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        provider.skuPickList.isEmpty
                        ? Container()
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TextWidget(
                              text: 'Subscribed Product', 
                              fontSize: 16, 
                              fontWeight: FontWeight.w500
                            ),
                            // Subscribed products list
                            SizedBox(
                              height: provider.skuPickList.length * 100,
                            // Subscribed products list
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: provider.skuPickList.length,
                                itemBuilder: (context, index) {
                                  SkuProduct product = provider.skuPickList[index];
                                  return Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        height: 80,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade400),
                                          borderRadius: BorderRadius.circular(8)
                                        ),
                                        child: Center(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                                // Product Name and Product Morning and evening Quantity
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: size.width * 0.55,
                                                    child: TextWidget(
                                                      text: '${product.productName}(${product.quantity})', 
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      maxLines: 1,
                                                      textOverflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                    SizedBox(
                                                    width: size.width * 0.5,
                                                    child: TextWidget(
                                                      text: 'Morning: ${product.mrgQty.toString()} - Evening: ${product.evgQty.toString()}',
                                                      textOverflow: TextOverflow.ellipsis,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w300,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // Product price and Increment counter
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  TextWidget(
                                                    text:'Price : ₹${product.productPrice.toString()}', 
                                                    fontSize: 14, 
                                                    fontWeight: FontWeight.w600, 
                                                    fontColor: const Color(0xFF60B47B)
                                                  ),
                                                  Container(
                                                    height: size.height * 0.04,
                                                    width: size.width * 0.22,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: Colors.grey.shade400),
                                                      borderRadius: BorderRadius.circular(8)
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        // Product Quantity decrease
                                                        GestureDetector(
                                                          onTap: (){
                                                            provider.additionalSku(product.productId, false);
                                                          },
                                                          child: Container(
                                                            width: size.width * 0.07,
                                                            height: size.height * 0.04,
                                                            decoration: BoxDecoration(
                                                              borderRadius: const BorderRadius.only(
                                                                topLeft: Radius.circular(8),
                                                                bottomLeft: Radius.circular(8)
                                                              ),
                                                              border: Border(right: BorderSide(color: Colors.grey.shade400,))
                                                            ),
                                                            child: const Icon(Icons.remove, size: 15,),
                                                          ),
                                                        ),
                                                        // Product Quantity Count
                                                        SizedBox(
                                                          width: size.width * 0.07,
                                                          child: Center(
                                                            child: Text(
                                                              '${provider.additonalSkuQuantities[product.productId]}',
                                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                                            ),
                                                          ),
                                                        ),
                                                        // Product Quantity increase
                                                        GestureDetector(
                                                          onTap: (){
                                                            provider.additionalSku(product.productId, true);
                                                          },
                                                          child: Container(
                                                            width: size.width * 0.07,
                                                            height: size.height * 0.04,
                                                            decoration: BoxDecoration(
                                                              borderRadius: const BorderRadius.only(
                                                                topRight: Radius.circular(8),
                                                                bottomRight: Radius.circular(8)
                                                              ),
                                                              border: Border(left: BorderSide(color: Colors.grey.shade400,))
                                                            ),
                                                            child: Icon(
                                                              Icons.add, 
                                                              size: 15,
                                                              color:
                                                               provider.additonalSkuQuantities[product.productId]! >= 1 
                                                              ? const Color(0xFF60B47B)
                                                              :  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                
                                                ],
                                              ),  
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10,)
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5,),
                        provider.orderedProducts.isNotEmpty
                        // Ordered Products
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Order Products Heading
                              const Text('Ordered Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                              const SizedBox(height: 5,),
                              // Ordered products list
                              SizedBox(
                                height: provider.orderedProducts.length * size.height * 0.13,
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: provider.orderedProducts.length,
                                  itemBuilder: (context, index) {
                                    OrderedProductsModel product = provider.orderedProducts[index];
                                    return Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          height: size.height * 0.1,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade400),
                                            borderRadius: BorderRadius.circular(8)
                                          ),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                // Product Name and Product Price
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: size.width * 0.55,
                                                      child: TextWidget(
                                                        text: '${product.productName}(Qty: ${product.quantity})', 
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                        maxLines: 1,
                                                        textOverflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: size.width * 0.5,
                                                      child: TextWidget(
                                                        text:'Price : ₹${product.price.toString()}', 
                                                        fontSize: 14, 
                                                        fontWeight: FontWeight.w600, 
                                                        fontColor: const Color(0xFF60B47B)
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // Product Description and increment counter
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                      height: size.height * 0.04,
                                                      width: size.width * 0.22,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.grey.shade400),
                                                        borderRadius: BorderRadius.circular(8)
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          // Product Quantity decrease
                                                          GestureDetector(
                                                            onTap: (){
                                                              provider.additionalOrder(index, false);
                                                              // setState(() {
                                                              //   if (provider.orderedProductsAdditionalQuantities[index] > 0) {
                                                              //     provider.orderedProductsAdditionalQuantities[index] = provider.orderedProductsAdditionalQuantities[index] - 1;
                                                              //   }
                                                              // });
                                                            },
                                                            child: Container(
                                                              width: size.width * 0.07,
                                                              height: size.height * 0.04,
                                                              decoration: BoxDecoration(
                                                                borderRadius: const BorderRadius.only(
                                                                  topLeft: Radius.circular(8),
                                                                  bottomLeft: Radius.circular(8)
                                                                ),
                                                                border: Border(right: BorderSide(color: Colors.grey.shade400,))
                                                              ),
                                                              child: const Icon(Icons.remove, size: 15,),
                                                            ),
                                                          ),
                                                          // Product Quantity Count
                                                          SizedBox(
                                                            width: size.width * 0.07,
                                                            child: Center(
                                                              child: Text(
                                                                '${provider.orderedProductsAdditionalQuantities[index]}',
                                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                                              ),
                                                            ),
                                                          ),
                                                          // Product Quantity increase
                                                          GestureDetector(
                                                            onTap: (){
                                                              provider.additionalOrder(index, true);
                                                              //   setState(() {
                                                              //   provider.orderedProductsAdditionalQuantities[index] = provider.orderedProductsAdditionalQuantities[index] + 1;
                                                              // });
                                                            },
                                                            child: Container(
                                                              width: size.width * 0.07,
                                                              height: size.height * 0.04,
                                                              decoration: BoxDecoration(
                                                                borderRadius: const BorderRadius.only(
                                                                  topRight: Radius.circular(8),
                                                                  bottomRight: Radius.circular(8)
                                                                ),
                                                                border: Border(left: BorderSide(color: Colors.grey.shade400,))
                                                              ),
                                                              child: Icon(
                                                                Icons.add, 
                                                                size: 15,
                                                                color: provider.orderedProductsAdditionalQuantities[index] >= 1 
                                                                ? const Color(0xFF60B47B)
                                                                :  Colors.black,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10,),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : Container(),
                        const SizedBox(height: 5,),
                        // All Products Heading
                        const Text('All Products', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                        const SizedBox(height: 5,),
                        // All products 
                        SizedBox(
                          height: provider.allProducts.length * 100,
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: provider.allProducts.length,
                            itemBuilder: (context, index) {
                              ProductsModel product = provider.allProducts[index];
                              return Column(
                                children: [
                                  Container(
                                    // height: size.height * 0.12,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade400),
                                    ),
                                    child: Center(
                                      child: Row(
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Product Name and Product Description
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: size.width * 0.55,
                                                child: TextWidget(
                                                  text: '${product.name}(Qty: ${product.quantity})', 
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  maxLines: 1,
                                                  textOverflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(
                                                width: size.width * 0.5,
                                                child: TextWidget(
                                                  text:  product.description.replaceAll("<p>", ""),
                                                  textOverflow: TextOverflow.ellipsis,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Product Description and increment counter
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              TextWidget(
                                                text:'Price : ₹${product.finalPrice.toString()}', 
                                                fontSize: 14, 
                                                fontWeight: FontWeight.w600, 
                                                fontColor: const Color(0xFF60B47B)
                                              ),
                                              Container(
                                                height: size.height * 0.04,
                                                width: size.width * 0.22,
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.grey.shade400),
                                                  borderRadius: BorderRadius.circular(8)
                                                ),
                                                child: Row(
                                                  children: [
                                                    // Product Quantity decrease
                                                    GestureDetector(
                                                      onTap: (){
                                                        // setState(() {
                                                        //   if (provider.additionalProductQuantities[product.id]! > 0) {
                                                        //     provider.additionalProductQuantities[product.id] = provider.additionalProductQuantities[product.id]! - 1;
                                                        //   }
                                                        // });
                                                        provider.additionalProduct(product.id, false);
                                                      },
                                                      child: Container(
                                                        width: size.width * 0.07,
                                                        height: size.height * 0.04,
                                                        decoration: BoxDecoration(
                                                          borderRadius: const BorderRadius.only(
                                                            topLeft: Radius.circular(8),
                                                            bottomLeft: Radius.circular(8)
                                                          ),
                                                          border: Border(right: BorderSide(color: Colors.grey.shade400,))
                                                        ),
                                                        child: const Icon(Icons.remove, size: 15,),
                                                      ),
                                                    ),
                                                    // Product Quantity Count
                                                    SizedBox(
                                                      width: size.width * 0.07,
                                                      child: Center(
                                                        child: Text(
                                                          '${provider.additionalProductQuantities[product.id]}',
                                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                                        ),
                                                      ),
                                                    ),
                                                    // Product Quantity increase
                                                    GestureDetector(
                                                      onTap: (){
                                                        //   setState(() {
                                                        //   provider.additionalProductQuantities[product.id] = provider.additionalProductQuantities[product.id]! + 1;
                                                        // });
                                                        provider.additionalProduct(product.id, true);
                                                      },
                                                      child: Container(
                                                        width: size.width * 0.07,
                                                        height: size.height * 0.04,
                                                        decoration: BoxDecoration(
                                                          borderRadius: const BorderRadius.only(
                                                            topRight: Radius.circular(8),
                                                            bottomRight: Radius.circular(8)
                                                          ),
                                                          border: Border(left: BorderSide(color: Colors.grey.shade400,))
                                                        ),
                                                        child: Icon(
                                                          Icons.add, 
                                                          size: 15,
                                                          color: provider.additionalProductQuantities[product.id]! >= 1 
                                                          ? const Color(0xFF60B47B)
                                                          :  Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10,),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  provider.allProducts.length == index
                                  ? const SizedBox(height: 200,) : const SizedBox(height: 10,),
                                ],
                              );
                            },
                          ),
                        ),  
                        // const SizedBox(height: 75,),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 12,
              right: 12,
              child: SizedBox(
                width: size.width,
                height: size.height * 0.06,
                child: provider.isPicking
                ? FloatingActionButton(
                    onPressed: (){
                      // provider.picked(false);
                    },
                    elevation: 0,
                    backgroundColor: const Color(0xFF60B47B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  )
                : FloatingActionButton(
                    elevation: 0,
                    backgroundColor: const Color(0xFF60B47B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    onPressed: () async {
                      // await _callApi(size);
                      provider.picked(true);
                      try {
                       await provider.pickupList(size, context);
                      } catch (e) {
                        print("Picking Failed: $e");
                      } finally{
                        provider.picked(false);
                      }
                    },
                    child: const TextWidget(
                      text: 'Enter Pickup Product', 
                      fontWeight: FontWeight.w400, 
                      fontSize: 16,
                      fontColor: Colors.white,
                    ),
                  ),
              ),
            ),
          ],
        );
      },
    );
  }

}

