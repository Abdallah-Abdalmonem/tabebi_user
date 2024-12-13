import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/app/routes.dart';
import 'package:tabebi/cubits/auth/cityCubit.dart';
import 'package:tabebi/helper/apiParams.dart';
import 'package:tabebi/helper/generaWidgets.dart';
import 'package:tabebi/helper/generalMethods.dart';
import 'package:tabebi/helper/stringLables.dart';
import 'package:tabebi/models/province.dart';
import '../../cubits/hospital/hospitalCubit.dart';
import '../../cubits/hospital/subscribedHospitalCubit.dart';
import '../../cubits/lab/labTestCubit.dart';
import '../../helper/constant.dart';
import '../../helper/sessionManager.dart';
import '../mainHome/mainPage.dart';

class CityListPage extends StatefulWidget {
  final Province? selectedProvince;
  final bool isFromSplash;
  const CityListPage(
      {Key? key, this.selectedProvince, required this.isFromSplash})
      : super(key: key);

  @override
  CityListPageState createState() => CityListPageState();
}

class CityListPageState extends State<CityListPage> {
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
    context.read<CityCubit>().getCityList(context,
        {ApiParams.provinceId: widget.selectedProvince!.id.toString()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralWidgets.setAppbar(
          getLables(
              widget.selectedProvince == null ? selectProvince : selectCity),
          context),
      body: contentWidget(),
    );
  }

  contentWidget() {
    return BlocBuilder<CityCubit, CityState>(
      builder: (context, state) {
        if (state is CityProgress) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is CityFailure) {
          return GeneralWidgets.msgWithTryAgain(
              state.errorMessage, () => getData());
        } else if (state is CitySuccess) {
          mainList.clear();
          if (edtSearch.text.trim().isEmpty) {
            mainList.add(Province(
                id: 0, name: getLables(lblAll), latitude: "0", longitude: "0"));
          }
          mainList.addAll(state.cityList);

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
          Province city = listContent[i];
          return GeneralWidgets.cardBoxWidget(
            celevation: 0,
            cradius: 5,
            childWidget: GeneralWidgets.setListtileMenu(city.name!, context,
                trailingwidget: const Icon(Icons.navigate_next),
                isdence: false,
                textStyle: Theme.of(context).textTheme.titleMedium!,
                onClickAction: () {
              String previouscityid =
                  Constant.session!.getData(SessionManager.keyCityId);
              //
              Constant.session!.setData(SessionManager.keyProvinceId,
                  widget.selectedProvince!.id.toString());
              Constant.session!.setData(SessionManager.keyProvinceName,
                  widget.selectedProvince!.name!);
              Constant.session!
                  .setData(SessionManager.keyCityId, city.id.toString());
              Constant.session!.setData(SessionManager.keyCityName, city.name!);
              //
              Future.delayed(Duration.zero, () {
                if (widget.isFromSplash) {
                  GeneralMethods.killPreviousPages(context, Routes.mainPage,
                      args: "city");
                } else {
                  if (currentUserCity != null && currentUserCity!.isClosed) {
                    currentUserCity = StreamController<bool>.broadcast();
                  }

                  if (currentUserCity != null && !currentUserCity!.isClosed) {
                    currentUserCity!.sink.add(
                        previouscityid == city.id.toString() ? false : true);
                  }
                  if (previouscityid != city.id.toString()) {
                    reloadData();
                  }
                  Navigator.of(context).pop(city.name!);
                }
              });
            }),
            //.merge(const TextStyle(color: Color(0xff45536D)))),
          );
        });
  }

  reloadData() {
    context.read<SubscribeHospitalCubit>().loadPosts(
        context, {ApiParams.isSubscribe: "1"},
        isloadlocal: false, setInitial: true);
    context
        .read<HospitalCubit>()
        .loadPosts(context, {}, isloadlocal: false, setInitial: true);
    if (context.read<LabTestCubit>().state is LabTestSuccess) {
      context
          .read<LabTestCubit>()
          .getLabTestList(context, {}, isSetInitial: true);
    }
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
