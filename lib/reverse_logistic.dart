import 'package:flutter/material.dart';

class ReverseOrder extends StatefulWidget {
  const ReverseOrder({super.key});

  @override
  State<ReverseOrder> createState() => _ReverseOrderState();
}

class _ReverseOrderState extends State<ReverseOrder> {
  late Color pendingColor = Colors.blue.shade300;
  late Color collectedColor = Colors.transparent;
  bool ispendingselected = true;
  bool iscollectedSelected = false;
  List<String> names = [
  'Arjun Kumar',
  'Priya Sharma',
  'Rajesh Patel',
  'Ananya Rajan',
];

List<String> addresses = [
  '123, South Veli Street, Madurai, Tamil Nadu, India',
  '456, East Masi Street, Madurai, Tamil Nadu, India',
  '789, West Perumal Street, Madurai, Tamil Nadu, India',
  '101, North Teppakulam Street, Madurai, Tamil Nadu, India',
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text('Reverse Logistic'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 210,
            // first box
            child: Column(
              children: [
                // search box
                Center(
                  child: Container(
                    height: 50,
                    width: 300,
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Search Customer Name',
                        suffixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.grey.withOpacity(0.5) 
                        )
                      ),
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                ),
                // tab selection
                Center(
                  child: Container(
                    height: 120,
                     width: 300,
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 5,),
                        const Center(
                          child: Text('Products'),
                        ),
                        const Divider(
                          color: Colors.black26,
                        ),
                        Row(
                          children: [
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    pendingColor = Colors.blue.shade300;
                                    collectedColor = Colors.transparent;
                                    ispendingselected = true;
                                    iscollectedSelected = false;
                                  });
                                },
                                child: Container(
                                  height: 70,
                                  decoration: BoxDecoration(
                                    border: Border(bottom: 
                                      BorderSide(color: pendingColor, width:2 )
                                    )
                                  ),
                                  width: 130,
                                  child: const Center(child: Text('Pending\n    10')),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 70,
                              child: VerticalDivider(color: Colors.black26,)
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    ispendingselected = false;
                                    pendingColor = Colors.transparent;
                                    iscollectedSelected = true;
                                    collectedColor = Colors.blue.shade300;
                                  });
                                },
                                child: Container(
                                  height: 70,
                                  decoration: BoxDecoration(
                                    border: Border(bottom: 
                                      BorderSide(color: collectedColor, width:2 )
                                      )
                                  ),
                                  // margin: const EdgeInsets.only(top: 20),
                                  width: 130,
                                  child: const Center(
                                    child: Text('Collected\n      0')
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          // remaning body
          if(ispendingselected)
            pending()
          else
            collected()
        ],
      ),
    );
  }
  Widget pending(){
    return SizedBox(
      height: 450,
      child: ListView.builder(
        itemCount: names.length,
        itemBuilder: (context, index) {
          return pendingList(names[index], addresses[index]);
        }, 
      ),
    );
  }
   Widget collected(){
    return Container();
  }

  Widget pendingList(String name, String address){
    return Container(
      width: 320,
      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
            child: Text(name,),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 10),
            child: Row(
              children: [
                const Icon(Icons.home, color: Colors.blue,),
                const SizedBox(width: 5,),
                Expanded(
                  child: Text(address)
                )
              ],
            ),
          ),
          const Divider(
            color: Colors.black26,
          ),
          Row(
            children: [
              details('Bottles', Icons.water_drop),
              const SizedBox(
                height: 25,
                child: VerticalDivider(
                  color: Colors.black26,
                ),
              ),
              details('Call customer', Icons.call),
              const SizedBox(
                height: 25,
                child: VerticalDivider(
                  color: Colors.black26,
                ),
              ),
              details('Direction', Icons.directions)
            ],
          )
        ],
      ),
    );
  }
  Widget details(String name, IconData icon){
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 4,),
          Text(name)
        ],
      ),
    );
  }
}

