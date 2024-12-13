import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/helper/apiParams.dart';
import 'package:tabebi/helper/colors.dart';
import 'package:tabebi/helper/constant.dart';
import 'package:tabebi/helper/designConfig.dart';
import 'package:tabebi/models/doctor.dart';
import 'package:tabebi/screens/doctorAppointment/DoctorList/filterSettings.dart';
import 'package:tabebi/screens/doctorAppointment/DoctorList/sortBySettings.dart';
import '../../../cubits/doctor/doctorCubit.dart';
import '../../../helper/generaWidgets.dart';
import '../../../helper/generalMethods.dart';
import '../../../helper/stringLables.dart';
import '../../mainHome/mainPage.dart';
import 'drListItemWidget.dart';

class DoctorListPage extends StatefulWidget {
  DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => DoctorListPageState();
}

class DoctorListPageState extends State<DoctorListPage> {
  TextEditingController edtSearch = TextEditingController();
  bool wasSearchTextEmpty = true;
  bool isShowBottomHeader = true;
  List<Doctor> loadedlist = [];
  final scrollController = ScrollController();
  int loadedpage = 1;
  int loadedoffset = 0;
  @override
  void initState() {
    super.initState();

    setupScrollController(context);
    if (BlocProvider.of<DoctorCubit>(context).state is! DoctorLoaded) {
      print("loadstate");
      loadPage();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadPage({bool isSetInitial = false}) {
    print("drparams->*====*${Constant.drGetListParams}");
    BlocProvider.of<DoctorCubit>(context).loadPosts(
        context, Constant.drGetListParams,
        isSetInitial: isSetInitial);
    print("currpage=${BlocProvider.of<DoctorCubit>(context).page}");
  }

  setupScrollController(context) {
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          loadPage();
        }
      }
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        //print("reverse---");
        if (isShowBottomHeader) isShowBottomHeader = false;
        if (currentUserCity != null && !currentUserCity!.isClosed) {
          currentUserCity!.sink.add(false);
        }
      }
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        //print("forward---");
        if (!isShowBottomHeader) isShowBottomHeader = true;
        if (currentUserCity != null && !currentUserCity!.isClosed) {
          currentUserCity!.sink.add(false);
        }
      }
      //
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (edtSearch.text.trim().isNotEmpty) {
          setAllList();
        }
        return Future.value(true);
      },
      child: Scaffold(
        appBar: GeneralWidgets.citySelectionAppbarWidget(
            context, getLables(findaDoctor),
            isShowBottomHeader: isShowBottomHeader, callback: loadPage),
        body: Column(
            children: [searchFilterWidget(), Expanded(child: contentWidget())]),
      ),
    );
  }

  searchFilterWidget() {
    return StreamBuilder<Object>(
        stream: currentUserCity!.stream,
        builder: (context, snapshot) {
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: isShowBottomHeader
                ? Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: grey,
                          offset: Offset(0.0, 1.0),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        searchWidget(),
                        const SizedBox(height: 10),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: filterBtnWidget(
                                      "filter", getLables(lblFilter), () {
                                    GeneralWidgets.showBottomSheet(
                                        btmchild: FilterSettings(
                                          doctorCubit:
                                              context.read<DoctorCubit>(),
                                        ),
                                        context: context);
                                  })),
                              const SizedBox(width: 8),
                              Expanded(
                                  flex: 1,
                                  child: filterBtnWidget(
                                      "sortby", getLables(lblSort), () {
                                    GeneralWidgets.showBottomSheet(
                                        btmchild: SortBySettings(
                                          doctorCubit:
                                              context.read<DoctorCubit>(),
                                        ),
                                        context: context);
                                  })),
                            ]),
                        const SizedBox(height: 5),
                      ],
                    ),
                  )
                : SizedBox.shrink(),
          );
        });
  }

  filterBtnWidget(String image, String lbl, Function callback) {
    return GestureDetector(
        onTap: () {
          callback();
        },
        child: GeneralWidgets.cardBoxWidget(
            cpadding: EdgeInsetsDirectional.symmetric(vertical: 10),
            celevation: 0,
            cmargin: EdgeInsetsDirectional.zero,
            cshape: DesignConfig.setRoundedBorder(5, true,
                bordercolor: lightGrey, bwidth: 0.5),
            childWidget: Row(children: [
              const SizedBox(width: 15),
              GeneralWidgets.setSvg(image, width: 20),
              const SizedBox(width: 12),
              Text(
                lbl,
                style: TextStyle(color: grey),
              )
            ])));

    /*  GeneralWidgets.setListtileMenu(getLables(lblFilter), context,
        leadingwidget: GeneralWidgets.setSvg("filter", width: 20),
        visualDensity: VisualDensity(vertical: -2),
        shapeBorder: DesignConfig.setRoundedBorder(5, true,
            bordercolor: lightGrey, bwidth: 0.5), onClickAction: () {
      GeneralWidgets.showBottomSheet(
          btmchild: FilterSettings(
            doctorCubit: context.read<DoctorCubit>(),
          ),
          context: context);
    }); */
  }

  searchWidget() {
    return GeneralWidgets.searchWidget(edtSearch, context, getLables(lblSearch),
        onSearchTextChanged: onSearchTextChanged,
        cardmargin: EdgeInsetsDirectional.symmetric(horizontal: 0),
        cardcolor: lightBg,
        verticalpadding: 0);
  }

  contentWidget() {
    return BlocBuilder<DoctorCubit, DoctorState>(
      builder: (context, state) {
        if (state is DoctorLoading && state.isFirstFetch) {
          return GeneralWidgets.loadingIndicator();
        } else if (state is DoctorFailure) {
          return GeneralWidgets.msgWithTryAgain(
              state.errorMessage, () => loadPage(isSetInitial: true));
        }

        return listContent(state);
      },
    );
  }

  listContent(DoctorState state) {
    List<Doctor> posts = [];
    bool isLoading = false;
    int currpage = 1;
    int curroffset = 0;
    if (state is DoctorLoading) {
      posts = state.oldDrList;
      isLoading = true;
      currpage = state.currPage;
      curroffset = state.currOffset;
    } else if (state is DoctorLoaded) {
      posts = state.doctorList;
      currpage = state.currPage;
      curroffset = state.currOffset;
    }

    if (edtSearch.text.trim().isEmpty && posts.isNotEmpty) {
      loadedpage = currpage;
      loadedoffset = curroffset;
      loadedlist = [];
      loadedlist = posts;
    }

    return RefreshIndicator(
      onRefresh: refreshList,
      child: ListView.separated(
        controller: scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          if (index < posts.length)
            return DrListItemWidget(
                post: posts[index], isDisplayHospital: true);
          //return doctorWidget(posts[index]);
          else {
            Timer(Duration(milliseconds: 30), () {
              scrollController
                  .jumpTo(scrollController.position.maxScrollExtent);
            });

            return GeneralWidgets.loadingIndicator();
          }
        },
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 10,
          );
        },
        itemCount: posts.length + (isLoading ? 1 : 0),
      ),
    );
  }

  onSearchTextChanged(String text) async {
    if ((wasSearchTextEmpty && text.trim().isNotEmpty) ||
        (!wasSearchTextEmpty && text.trim().isEmpty)) {
      wasSearchTextEmpty = text.trim().isEmpty;
      if (currentUserCity != null && !currentUserCity!.isClosed) {
        currentUserCity!.sink.add(false);
      }
    }
    if (text.isEmpty) {
      // setState(() {});
      print(
          "emptry-search---${currentUserCity == null}===${currentUserCity!.isClosed}");

      setAllList();
      return;
    }
    Constant.drGetListParams[ApiParams.search] = text;
    loadPage(isSetInitial: true);
  }

  setAllList() {
    Constant.drGetListParams.remove(ApiParams.search);
    BlocProvider.of<DoctorCubit>(context)
        .setOldList(loadedoffset, loadedpage, loadedlist);
  }

  Future<void> refreshList() async {
    loadPage(isSetInitial: true);
  }
}
