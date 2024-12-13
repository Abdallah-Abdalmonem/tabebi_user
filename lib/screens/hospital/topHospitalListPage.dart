import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/hospital/subscribedHospitalCubit.dart';
import '../../helper/apiParams.dart';
import '../../helper/generaWidgets.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';
import '../../models/hospital.dart';

class TopHospitalListPage extends StatefulWidget {
  final Map<String, String>? extraparams;
  const TopHospitalListPage({Key? key, this.extraparams}) : super(key: key);

  @override
  TopHospitalListPageState createState() => TopHospitalListPageState();
}

class TopHospitalListPageState extends State<TopHospitalListPage> {
  final scrollController = ScrollController();
  TextEditingController edtSearch = TextEditingController();
  List<Hospital> loadedlist = [];
  int loadedpage = 1, loadedoffset = 0;
  @override
  void initState() {
    super.initState();
    print("init===****speciality");
    setupScrollController(context);
    if (BlocProvider.of<SubscribeHospitalCubit>(context).state
        is! SubscribeHospitalSuccess) {
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
        "currpage=${BlocProvider.of<SubscribeHospitalCubit>(context).offset}==$isSetInitial");
    if (isSetInitial) {
      BlocProvider.of<SubscribeHospitalCubit>(context).setInitialState();
    }
    BlocProvider.of<SubscribeHospitalCubit>(context)
        .loadPosts(context, parameter);
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
        appBar:
            GeneralWidgets.setAppbar(getLables(homeHospitalHeader), context),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<SubscribeHospitalCubit, SubscribeHospitalState>(
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

  contentWidget(SubscribeHospitalState state) {
    if (state is SubscribeHospitalProgress && state.isFirstFetch) {
      return GeneralWidgets.loadingIndicator();
    } else if (state is SubscribeHospitalFailure) {
      return GeneralWidgets.msgWithTryAgain(
          state.errorMessage, () => loadPage(isSetInitial: true));
    }
    return listContent(state);
  }

  listContent(SubscribeHospitalState state) {
    List<Hospital> posts = [];
    bool isLoading = false;
    int currpage = 1;
    int curroffset = 0;
    if (state is SubscribeHospitalProgress) {
      posts = state.oldHospitalList;
      isLoading = true;
      currpage = state.currPage;
      curroffset = state.currOffset;
    } else if (state is SubscribeHospitalSuccess) {
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
    BlocProvider.of<SubscribeHospitalCubit>(context)
        .setOldList(loadedoffset, loadedpage, loadedlist);
  }
}
