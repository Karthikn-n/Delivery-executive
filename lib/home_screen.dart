import 'package:app_5/delivery_list.dart';
import 'package:app_5/reverse_logistic.dart';
import 'package:app_5/sku_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF60B47B),
        title: const Text('Mr.Root', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            SystemNavigator.pop();
          },
          child: Center(
            // padding: const EdgeInsets.only(left: 10, top: 4),
            child: SizedBox(
              height: 25,
              width: 25,
              child: Image.asset('assets/exit.png')
            ),
          ),
        ),
        actions: [
          action()
        ],
      ),
      body: Column(
        children: [
          // profile
          Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                child: Container(
                 height: 210,
                  decoration: const BoxDecoration(
                    color: Color(0xFF60B47B)
                  ),
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    margin: const EdgeInsets.only(left: 25),
                    child: const Text('P Ramanujam', style: TextStyle(fontSize: 18, color: Colors.white),),
                  ),
                ),
              ),
              Container(
                height: 105,
                margin: const EdgeInsets.only(right: 240, top: 150),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color:  Color.fromARGB(255, 100, 233, 142)
                ),
                child: const Center(
                  child: Icon(
                    Icons.delivery_dining_outlined,
                    size: 62,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: 210,
                left: 130,
                right: 0,
                child: Text('Delivery Executive', style:  TextStyle(color: Colors.grey.shade400),)
              )
            ],
          ),
          const SizedBox(height: 50,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 8,),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SKUList(),));
                      },
                      child: boxes('assets/home1.png', 'SKU Pick List', const Color.fromARGB(255, 141, 212, 163))
                    ),
                    const SizedBox(width: 20,),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DeliveryListPage(),)),
                      child: boxes('assets/home3.png', 'Delivery List', const Color.fromARGB(255, 141, 212, 163))
                    )
                  ],
                ),
              ),
              // SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ReverseOrder(),));
                  },
                  child: boxes('assets/home2.png', 'Reverse\nLogistics', const Color.fromARGB(255, 141, 212, 163))
                ),
              )
            ],
          )
        ],
      )
    );
  }
  Widget action(){
    return Container(
      height: 25,
      width: 104,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(6)
      ),
      child: const Row(
        children: [
          SizedBox( width: 5,),
          Icon(Icons.phone, size: 12, color: Colors.white,),
          SizedBox( width: 5,),
          Text('Call Manager', style: TextStyle(fontSize: 12, color: Colors.white),),
          SizedBox( width: 4,),
        ],
      ),
    );
  }
  Widget boxes(String image, String name, Color color){
    return Container(
        height: 80,
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color,
        ),
        child: Row(
          children: [
            const SizedBox(width: 6,),
            SizedBox(
              height: 50,
              width: 40,
              child: Image.asset(
                image,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 60,
              child: VerticalDivider(
                thickness: 1,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4,),
            Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600
              ),
            )
          ],
        ),
      );
                    
  }
}