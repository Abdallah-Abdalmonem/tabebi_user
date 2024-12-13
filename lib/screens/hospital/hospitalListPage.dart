import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/hospital/hospitalCubit.dart';
import '../../helper/apiParams.dart';
import '../../helper/generaWidgets.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';
import '../../models/hospital.dart';

class HospitalListPage extends StatefulWidget {
  final Map<String, String>? extraparams;
  const HospitalListPage({Key? key, this.extraparams}) : super(key: key);

  @override
  HospitalListPageState createState() => HospitalListPageState();
}

class HospitalListPageState extends State<HospitalListPage> {
  final scrollController = ScrollController();
  TextEditingController edtSearch = TextEditingController();
  List<Hospital> loadedlist = [];
  int loadedpage = 1, loadedoffset = 0;
  @override
  void initState() {
    super.initState();
    print("init===****speciality");
    setupScrollController(context);
    if (BlocProvider.of<HospitalCubit>(context).state is! HospitalSuccess) {
      print("loadstate===****speciality");
      loadPage();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadPage({bool isSetInitial = false, Map<String, String>? parameter}) {
    parameter ??= {};
    if (widget.extraparams != null) {
      parameter.addAll(widget.extraparams!);
    }
    print(
        "currpage=${BlocProvider.of<HospitalCubit>(context).offset}==$isSetInitial");
    if (isSetInitial) {
      BlocProvider.of<HospitalCubit>(context).setInitialState();
    }
    BlocProvider.of<HospitalCubit>(context).loadPosts(context, parameter);
  }

  setupScrollController(context) {
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          loadPage();
        }
      }
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
        appBar: GeneralWidgets.setAppbar(getLables(lblHospitals), context),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<HospitalCubit, HospitalState>(
            builder: (context, state) {
              return Column(children: [
                GeneralWidgets.searchWidget(
                    edtSearch, context, getLables(lblSearch),
                    onSearchTextChanged: onSearchTextChanged),
                Expanded(child: contentWidget(state))
              ]);
            },
          ),
        ),
      ),
    );
  }

  contentWidget(HospitalState state) {
    print("state=>$state");
    if (state is HospitalProgress && state.isFirstFetch) {
      return GeneralWidgets.loadingIndicator();
    } else if (state is HospitalFailure) {
      return GeneralWidgets.msgWithTryAgain(
          state.errorMessage, () => loadPage(isSetInitial: true));
    }
    return listContent(state);
  }

  listContent(HospitalState state) {
    List<Hospital> posts = [];
    bool isLoading = false;
    int currpage = 1;
    int curroffset = 0;
    if (state is HospitalProgress) {
      posts = state.oldHospitalList;
      isLoading = true;
      currpage = state.currPage;
      curroffset = state.currOffset;
    } else if (state is HospitalSuccess) {
      posts = state.hospitalList;
      currpage = state.currPage;
      curroffset = state.currOffset;
    }

    if (edtSearch.text.trim().isEmpty && posts.isNotEmpty) {
      loadedpage = currpage;
      loadedoffset = curroffset;
      loadedlist = [];
      loadedlist = posts;
    }

    return ListView.separated(
      controller: scrollController,
      separatorBuilder: (context, index) {
        return SizedBox(
          height: 10,
        );
      },
      itemBuilder: (context, index) {
        if (index < posts.length)
          return GeneralWidgets.hospitalWidget(posts[index], context);
        else {
          Timer(Duration(milliseconds: 30), () {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
          });

          return GeneralWidgets.loadingIndicator();
        }
      },
      itemCount: posts.length + (isLoading ? 1 : 0),
    );
  }

  onSearchTextChanged(String text) async {
    if (text.isEmpty) {
      // setState(() {});
      print("emptry-search");
      setAllList();
      return;
    }

    loadPage(isSetInitial: true, parameter: {ApiParams.search: text});
  }

  setAllList() {
    BlocProvider.of<HospitalCubit>(context)
        .setOldList(loadedoffset, loadedpage, loadedlist);
  }
}
