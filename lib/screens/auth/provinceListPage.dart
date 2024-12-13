import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/app/routes.dart';
import 'package:tabebi/cubits/auth/provinceCubit.dart';
import 'package:tabebi/helper/generaWidgets.dart';
import 'package:tabebi/helper/generalMethods.dart';
import 'package:tabebi/helper/stringLables.dart';
import 'package:tabebi/models/province.dart';

class ProvinceListPage extends StatefulWidget {
  final bool isFromSplash;
  const ProvinceListPage({Key? key, required this.isFromSplash})
      : super(key: key);

  @override
  ProvinceListPageState createState() => ProvinceListPageState();
}

class ProvinceListPageState extends State<ProvinceListPage> {
  TextEditingController edtSearch = TextEditingController();
  List<Province> searchResult = [];
  List<Province> mainList = [];

  @override
  void initState() {
    super.initState();
    searchResult = [];

    getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getData() {
    mainList = [];
    context.read<ProvinceCubit>().getProvinceList(context, {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralWidgets.setAppbar(getLables(selectProvince), context),
      body: contentWidget(),
    );
  }

  contentWidget() {
    return BlocBuilder<ProvinceCubit, ProvinceState>(
      builder: (context, state) {
        if (state is ProvinceProgress) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is ProvinceFailure) {
          return GeneralWidgets.msgWithTryAgain(
              state.errorMessage, () => getData());
        } else if (state is ProvinceSuccess) {
          mainList.clear();
          mainList.addAll(state.provinceList);

          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                GeneralWidgets.searchWidget(
                    edtSearch, context, getLables(lblSearch),
                    onSearchTextChanged: onSearchTextChanged),
                Expanded(child: listWidget())
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  listWidget() {
    List<Province> listContent = [];
    if (searchResult.isNotEmpty || edtSearch.text.trim().isNotEmpty) {
      listContent.addAll(searchResult);
    } else {
      listContent.addAll(mainList);
    }
    print("listsize--${listContent.length}");
    if (listContent.isEmpty) {
      return Center(child: Text(getLables(dataNotFoundErrorMessage)));
    }
    return ListView.builder(
        itemCount: listContent.length,
        itemBuilder: (context, i) {
          Province province = listContent[i];
          return GeneralWidgets.cardBoxWidget(
            celevation: 0,
            cradius: 5,
            childWidget: GeneralWidgets.setListtileMenu(province.name!, context,
                trailingwidget: const Icon(Icons.navigate_next),
                isdence: false,
                textStyle: Theme.of(context).textTheme.titleMedium!,
                onClickAction: () {
              GeneralMethods.goToNextPage(Routes.selectCityPage, context,
                  widget.isFromSplash ? false : true, args: {
                "selectedProvince": province,
                "isFromSplash": widget.isFromSplash
              });
            }),
            //.merge(const TextStyle(color: Color(0xff45536D)))),
          );
        });
  }

/*
  searchWidget() {
    return GeneralWidgets.cardBoxWidget(
      celevation: 0,
      cradius: 5,
      childWidget: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
                child: TextField(
              controller: edtSearch,
              decoration: InputDecoration(
                  hintText: getLables(lblSearch),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero),
              onChanged: onSearchTextChanged,
            )),
            IconButton(
              padding: EdgeInsets.zero,
              icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => RotationTransition(
                        turns: child.key == const ValueKey('icon1')
                            ? Tween<double>(begin: 1, end: 0).animate(anim)
                            : Tween<double>(begin: 0, end: 1).animate(anim),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                  child: Icon(
                    edtSearch.text.trim().isEmpty ? Icons.search : Icons.clear,
                    size: edtSearch.text.trim().isEmpty ? 35 : 25,
                    key: ValueKey(
                        edtSearch.text.trim().isEmpty ? 'icon1' : 'icon2'),
                    color: Theme.of(context).colorScheme.primary,
                  )),
              onPressed: () {
                if (edtSearch.text.trim().isEmpty) return;
                edtSearch.clear();
                onSearchTextChanged('');
              },
            )
          ],
        ),
      ),
    );
  }
*/
  onSearchTextChanged(String text) async {
    searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    for (var userDetail in mainList) {
      if (userDetail.name!
          .trim()
          .toLowerCase()
          .contains(text.trim().toLowerCase())) searchResult.add(userDetail);
    }

    setState(() {});
  }
}
