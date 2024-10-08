import 'package:exinflow/controllers/subtab.dart';
import 'package:exinflow/controllers/user.dart';
import 'package:exinflow/services/category.dart';
import 'package:exinflow/widgets/alert.dart';
import 'package:exinflow/widgets/padding.dart';
import 'package:exinflow/widgets/select_icon.dart';
import 'package:exinflow/widgets/select_color.dart';
import 'package:exinflow/widgets/subtab.dart';
import 'package:flutter/material.dart';
import 'package:exinflow/widgets/top_bar.dart';
import 'package:exinflow/constants/constants.dart';
import 'package:exinflow/constants/data.dart';
import 'package:exinflow/controllers/category.dart';
import 'package:exinflow/controllers/user.dart';
import 'package:exinflow/controllers/icon.dart';
import 'package:exinflow/controllers/color.dart';
import 'package:exinflow/models/category.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; 

class CategoryDetail extends StatefulWidget {
  final String id;
  final int subIndex;
  final String action;
  final String from;
  final String sub;

  CategoryDetail({
    Key? key,
    required this.id,
    required this.subIndex,
    required this.action,
    required this.from,
    required this.sub
  }): super(key: key);

  @override
  State<CategoryDetail> createState() => _CategoryDetailState();
}

class _CategoryDetailState extends State<CategoryDetail> {
  final user = FirebaseAuth.instance.currentUser;
  final CategoryService categoryService = CategoryService();

  final UserController userController = Get.find<UserController>();
  final OneSubtabController oneSubtabController = Get.find<OneSubtabController>();
  final AllSubtabController allSubtabController = Get.find<AllSubtabController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final IconController iconController = Get.find<IconController>();
  final ColorController colorController = Get.find<ColorController>();
  late TabController categoryTabController;
  late StreamSubscription<int> thisSelectedTabSubscription;

  CategoryModel currentC = CategoryModel(
    id: '',
    name: '',
    typeId: 0,
    subs: null,
    icon: '',
    color: '',
    isDeleted: false
  );

  SubcategoryModel currentS = SubcategoryModel(
    name: '',
    icon: '',
    isDeleted: false
  );

  final List<Map> tabs = [
    {
      "tab": "Pengeluaran",
      "title": "Kategori Pengeluaran"
    },
    {
      "tab": "Pendapatan",
      "title": "Kategori Pendapatan"
    },
  ];

  @override
  void initState() {
    super.initState();

    Get.delete<TabController>(tag: 'categoryTabController');
    categoryTabController = Get.put(
      TabController(length: tabs.length, vsync: Scaffold.of(context)),
      tag: 'categoryTabController'
    );

    thisSelectedTabSubscription = oneSubtabController.selectedTab.listen((index) {
      categoryTabController.animateTo(index);
    });

    if(widget.sub == 'category') {
      currentC.name = widget.action == 'add' ? '' : categoryController.category?.name ?? '';
      currentC.typeId = widget.action == 'add' ? 0 : categoryController.category?.typeId ?? 0;
      currentC.icon = widget.action == 'add' ? '' : categoryController.category?.icon ?? '';
      currentC.color = widget.action == 'add' ? '' : categoryController.category?.color ?? '';
    } else {
      currentS.name = widget.action == 'add' ? '' : categoryController.category?.subs![widget.subIndex].name ?? '';
      currentS.icon = widget.action == 'add' ? '' : categoryController.category?.subs![widget.subIndex].icon ?? '';
    }

    iconController.changeIcon('');
    colorController.changeColor('');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      oneSubtabController.changeTab(0);
      if(widget.sub == 'category') {
        if(widget.action == 'add') {
          oneSubtabController.changeTab(allSubtabController.selectedTab.value);
        } else {
          oneSubtabController.changeTab(currentC.typeId);
        }
      }
    });
  }

  @override
  void dispose() {
    thisSelectedTabSubscription.cancel();
    Get.delete<TabController>(tag: 'categoryTabController');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TabController categoryTabController = Get.put(
      TabController(length: tabs.length, vsync: Scaffold.of(context)),
      tag: 'categoryTabController'
    );
    
    oneSubtabController.selectedTab.listen((index) {
      if(index <= tabs.length - 1) {
        categoryTabController.animateTo(index);
      }
    });

    return Scaffold(
      appBar: TopBar(
        id: widget.id,
        title: "Detail",
        menu: "Kategori",
        page: "Detail",
        type: widget.action,
        from: widget.from,
        subtype: widget.sub == 'subcategory' ? 'subcategory' : 'category',
        subIndex: widget.sub == 'subcategory' ? widget.subIndex : -1
      ),

      body: Center(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: AllPadding(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 75),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(widget.sub == 'category') 
                        Subtab(tabs: tabs, type: 'one', disabled: widget.action != 'add' ? true : false, controller: categoryTabController),

                      if(widget.sub == 'category')
                        Padding(
                          padding: const EdgeInsets.only(bottom: 17.5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  "Nama",
                                  style: TextStyle(
                                    fontSize: small,
                                    color: greyMinusTwo
                                  ),
                                ),
                              ),
                              TextFormField(
                                enabled: widget.action == 'add' || widget.action == 'edit' ? true : false,
                                onChanged: (value) {
                                  setState(() {
                                    if(widget.sub != 'subcategory') {
                                      currentC.name = value;
                                    } else {
                                      currentS.name = value;
                                    }
                                  });
                                },
                                initialValue: widget.sub != 'subcategory' ? currentC.name : currentS.name,
                                style: TextStyle(
                                  fontSize: semiVerySmall
                                ),
                                decoration: InputDecoration(
                                  hintText: widget.action == 'view' ? categoryController.category?.name ?? '' : 'Nama ${widget.sub == 'category' ? 'kategori' : 'subkategori'}',
                                  hintStyle: TextStyle(
                                    color: greyMinusThree
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(width: 1, color: mainBlueMinusThree),
                                    borderRadius: borderRadius
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 1, color: greyMinusFour),
                                    borderRadius: borderRadius
                                  ),
                                ),
                                keyboardType: TextInputType.name,
                              )
                            ],
                          ),
                        ),
                  
                      Padding(
                        padding: const EdgeInsets.only(bottom: 17.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    "Ikon",
                                    style: TextStyle(
                                      fontSize: small,
                                      color: greyMinusTwo
                                    ),
                                  ),
                                ),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: greyMinusFour, width: 1),
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.all(0),
                                    padding: EdgeInsets.all(0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Obx(() {
                                        return IconButton(
                                          icon: iconController.selectedIcon.value != '' ? Obx(() {
                                            return Icon(
                                              icons[iconController.selectedIcon.value],
                                              size: 30,
                                              color: greyMinusTwo
                                            );
                                          }) : Icon(
                                            widget.action == 'view' ? icons[widget.sub == 'subcategory' ? currentS.icon : currentC.icon] : widget.action == 'add' ? iconController.selectedIcon.value != '' ? icons[iconController.selectedIcon.value] : Icons.add_rounded : iconController.selectedIcon.value != '' ? icons[iconController.selectedIcon.value] : icons[widget.sub == 'subcategory' ? currentS.icon : currentC.icon],
                                            size: 30,
                                            color: greyMinusTwo
                                          ),
                                          onPressed: widget.action == 'add' || widget.action == 'edit' ? () {
                                            SelectIcon selectIcon = SelectIcon();
                                            selectIcon.show(context);
                                          } : null,
                                        );
                                      }),
                                    )
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    widget.sub == 'subcategory' ? 'Nama' : "Warna",
                                    style: TextStyle(
                                      fontSize: small,
                                      color: greyMinusTwo
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 285,
                                  child: widget.sub == 'subcategory' ? TextFormField(
                                    enabled: widget.action == 'add' || widget.action == 'edit' ? true : false,
                                    onChanged: (value) {
                                      setState(() {
                                        currentS.name = value;
                                      });
                                    },
                                    initialValue: currentS.name,
                                    style: TextStyle(
                                      fontSize: semiVerySmall
                                    ),
                                    decoration: InputDecoration(
                                      hintText: widget.action == 'view' ? categoryController.category?.name ?? '' : 'Nama ${widget.sub == 'subcategory' ? 'subkategori' : 'kategori'}',
                                      hintStyle: TextStyle(
                                        color: greyMinusThree
                                      ),
                                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(width: 1, color: mainBlueMinusThree),
                                        borderRadius: borderRadius
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(width: 1, color: greyMinusFour),
                                        borderRadius: borderRadius
                                      ),
                                    ),
                                    keyboardType: TextInputType.name,
                                  ) : DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: greyMinusFour, width: 1),
                                      borderRadius: borderRadius
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                      child: Obx(() {
                                        return Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          child: colorController.selectedColor.value != '' ? Obx(() {
                                            return ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(int.parse("FF${colorController.selectedColor.value}", radix: 16)),
                                                disabledBackgroundColor: Color(int.parse("FF${colorController.selectedColor.value}", radix: 16)),
                                              ),
                                              child: Text(
                                                '',
                                                style: TextStyle(
                                                  fontSize: semiVerySmall
                                                )
                                              ),
                                              onPressed: widget.action == 'add' || widget.action == 'edit' ? () {
                                                SelectColor selectColor = SelectColor();
                                                selectColor.show(context);
                                              } : null,
                                            );
                                          }) : ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              disabledBackgroundColor: Color(int.parse("FF${widget.action == 'view' ? currentC.color : widget.action == 'add' ? colorController.selectedColor.value != '' ? colorController.selectedColor.value : '0f667b' : colorController.selectedColor.value != '' ? colorController.selectedColor.value : currentC.color}", radix: 16)),
                                              backgroundColor: Color(int.parse("FF${widget.action == 'view' ? currentC.color : widget.action == 'add' ? colorController.selectedColor.value != '' ? colorController.selectedColor.value : '0f667b' : colorController.selectedColor.value != '' ? colorController.selectedColor.value : currentC.color}", radix: 16)),
                                            ),
                                            child: Text(
                                              '',
                                              style: TextStyle(
                                                fontSize: semiVerySmall
                                              )
                                            ),
                                            onPressed: widget.action == 'add' || widget.action == 'edit' ? () {
                                              SelectColor selectColor = SelectColor();
                                              selectColor.show(context);
                                            } : null,
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              )
            ),

            AllPadding(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: widget.action == 'view' ? null : OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: widget.action == 'add' || widget.action == 'edit' ? mainBlueMinusTwo : Colors.transparent,
                    side: BorderSide(color: widget.action == 'add' || widget.action == 'edit' ? Colors.transparent : mainBlueMinusTwo),
                    padding: EdgeInsets.all(widget.action == 'add' || widget.action == 'edit' ? 15 : 5)
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Simpan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: small,
                            fontWeight: FontWeight.w500
                          )
                        )
                      ],
                    ),
                  ),
                  onPressed: () async {
                    CategoryModel dataC = currentC;
                    SubcategoryModel dataS = currentS;
                    Map<String, dynamic> result = {};
                    if(currentC.name == '') {
                      result = {
                        'success': false,
                        'message': 'Nama akun harus diisi'
                      };
                      print(result);
                    } else {
                      if(widget.action == 'add') {
                        if(widget.sub == 'category') {
                          dataC.typeId = oneSubtabController.selectedTab.value;
                          dataC.icon = iconController.selectedIcon.value == '' ? 'account_balance_wallet_outlined' : iconController.selectedIcon.value;
                          dataC.color = colorController.selectedColor.value == '' ? '0f667b' : colorController.selectedColor.value;

                          result = await categoryService.createCategory(user?.uid ?? '', false, dataC);
                        }
                        if(widget.sub == 'subcategory') {
                          dataS.icon = iconController.selectedIcon.value == '' ? 'account_balance_wallet_outlined' : iconController.selectedIcon.value;

                          result = await categoryService.createSubcategory(user?.uid ?? '', false, widget.id, dataS);
                        }
                      } else if(widget.action == 'edit') {
                        if(widget.sub == 'category') {
                          dataC.icon = iconController.selectedIcon.value == '' ? currentC.icon : iconController.selectedIcon.value;
                          dataC.color = colorController.selectedColor.value == '' ? currentC.color : colorController.selectedColor.value;

                          result = await categoryService.updateCategory(user?.uid ?? '', widget.id, dataC);
                        }
                        if(widget.sub == 'subcategory') {
                          dataS.icon = iconController.selectedIcon.value == '' ? currentC.icon : iconController.selectedIcon.value;
                          
                          result = await categoryService.updateSubcategory(user?.uid ?? '', widget.id, widget.subIndex, dataS);
                        }
                      }

                      if(result['success'] == true) {
                        context.pop();
                        allSubtabController.changeTab(oneSubtabController.selectedTab.value);
                      }
                    }
                  },
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}