import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/app/routes.dart';
import 'package:tabebi/cubits/specialityCubit.dart';
import 'package:tabebi/helper/apiParams.dart';
import 'package:tabebi/models/speciality.dart';
import '../../helper/constant.dart';
import '../../helper/generaWidgets.dart';
import '../../helper/generalMethods.dart';
import '../../helper/stringLables.dart';

class SpecialityListPage extends StatefulWidget {
  const SpecialityListPage({super.key});

  @override
  State<SpecialityListPage> createState() => SpecialityListPageState();
}

class SpecialityListPageState extends State<SpecialityListPage> {
  final scrollController = ScrollController();
  TextEditingController edtSearch = TextEditingController();
  List<Speciality> loadedlist = [];
  int loadedpage = 1, loadedoffset = 0;
  @override
  void initState() {
    super.initState();

    setupScrollController(context);
    if (BlocProvider.of<SpecialityCubit>(context).state is! SpecialitySuccess) {
      loadPage();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadPage({bool isSetInitial = false, Map<String, String>? parameter}) {
    parameter ??= {};

    if (isSetInitial) {
      BlocProvider.of<SpecialityCubit>(context).setInitialState();
    }
    BlocProvider.of<SpecialityCubit>(context).loadPosts(context, parameter);
  }

  setupScrollController(context) {
    scrollController.addListener(() {
      print("scroll->${scrollController.position}");
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
        appBar: GeneralWidgets.setAppbar(getLables(searchForSpeciality), context),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<SpecialityCubit, SpecialityState>(
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

  contentWidget(SpecialityState state) {
    if (state is SpecialityProgress && state.isFirstFetch) {
      return GeneralWidgets.loadingIndicator();
    } else if (state is SpecialityFailure) {
      return GeneralWidgets.msgWithTryAgain(
          state.errorMessage, () => loadPage(isSetInitial: true));
    }
    return listContent(state);
  }

  specialityWidget(Speciality post, BuildContext context) {
    return GeneralWidgets.cardBoxWidget(
        celevation: 0,
        cpadding: EdgeInsetsDirectional.symmetric(vertical: 8),
        childWidget: GestureDetector(
          onTap: () {
            Constant.drGetListParams = {};
            Constant.drGetListParams[ApiParams.specialityId] =
                post.id.toString();

            GeneralMethods.goToNextPage(
              Routes.doctorlistpage,
              context,
              false,
            );
          },
          child: Row(children: [
            const SizedBox(width: 10),
            GeneralWidgets.circularImage(post.image),
            const SizedBox(width: 12),
            Expanded(
                child: Text(
              post.name!,
              style: Theme.of(context).textTheme.bodyMedium,
            ))
          ]),
        ));
  }

  listContent(SpecialityState state) {
    List<Speciality> posts = [];
    bool isLoading = false;
    int currpage = 1;
    int curroffset = 0;
    if (state is SpecialityProgress) {
      posts = state.oldSpecialityList;
      isLoading = true;
      currpage = state.currPage;
      curroffset = state.currOffset;
    } else if (state is SpecialitySuccess) {
      posts = state.specialityList;
      currpage = state.currPage;
      curroffset = state.currOffset;
    }

    if (edtSearch.text.trim().isEmpty && posts.isNotEmpty) {
      loadedpage = currpage;
      loadedoffset = curroffset;
      loadedlist = [];
      loadedlist = posts;
    }

    return ListView.builder(
      controller: scrollController,
      itemBuilder: (context, index) {
        if (index < posts.length)
          return specialityWidget(posts[index], context);
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
    if (text.trim().isEmpty) {
      // setState(() {});
      print("emptry-search");
      setAllList();
      return;
    }

    loadPage(isSetInitial: true, parameter: {ApiParams.search: text});
  }

  setAllList() {
    BlocProvider.of<SpecialityCubit>(context)
        .setOldList(loadedoffset, loadedpage, loadedlist);
  }
}
