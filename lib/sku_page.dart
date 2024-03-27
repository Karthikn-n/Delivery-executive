import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SKUList extends StatefulWidget {
  const SKUList({super.key});

  @override
  State<SKUList> createState() => _SKUListState();
}

class _SKUListState extends State<SKUList> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2050, 12, 31),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  List<String> image = [
    'https://images.unsplash.com/photo-1626810257238-19db99ca6c4c?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/photo-1601055903647-ddf1ee9701b7?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/photo-1592839971356-a9a5d258c1af?q=80&w=1471&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'
  ];

  List<String> name = [
    'Farm Fresh Lemon (Bottle)',
    'Sidral Mundet Fresh juice (Bottle)',
    'Mixture Juice (Bottle)'
  ];

  List<String> weight = [
    '500ml',
    '350ml',
    '500ml'
  ];

  List<String> quantity = ['16','9','31'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SKU Pick List'),
        actions: [action()],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10,),
        child: ListView.builder(
          itemCount: image.length,
          itemBuilder: (context, index) {
            return skuList(image[index], name[index], weight[index], quantity[index]);
          },
        )
      ),
    );
  }
  Widget action(){
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        height: 25,
        width: 104,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(6)
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month),
            Text(
              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget skuList(String image, String title, String weight, String quantity){
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Card(
        child: ListTile(
          tileColor: Colors.grey.shade200,
          style: ListTileStyle.list,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)
          ),
          leading: SizedBox(
            height: 60,
            width: 60,
            child: CachedNetworkImage(
              imageUrl: image,
              fit: BoxFit.cover,
            )
          ),
          title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),),
          subtitle: Text(weight),
          titleAlignment: ListTileTitleAlignment.titleHeight,
          subtitleTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade400),
          trailing: Text('Qty : $quantity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue.shade400),),
        ),
      ),
    );
  }
}