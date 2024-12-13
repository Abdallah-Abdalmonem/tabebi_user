import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabebi/cubits/lab/labTestCubit.dart';
import 'package:tabebi/helper/colors.dart';
import 'package:tabebi/helper/constant.dart';
import 'package:tabebi/helper/stringLables.dart';
import 'package:tabebi/models/labTest.dart';
import '../../cubits/lab/labCubit.dart';
import '../../helper/apiParams.dart';
import '../../helper/generaWidgets.dart';
import '../../helper/generalMethods.dart';
import 'labListPage.dart';

class TestListPage extends StatefulWidget {
  final LabCubit? labCubit;
  final String? labid;
  final List<LabTest>? labTestList;

  const TestListPage(
      {Key? key, required this.labCubit, this.labid, this.labTestList})
      : super(key: key);

  @override
  TestListPageState createState() => TestListPageState();
}

class TestListPageState extends State<TestListPage> {
  //List<LabTest> searchResult = [];
  //List<LabTest> mainList = [];
  bool isFromSearch = false, isChange = false;
  final scrollController = ScrollController();
  TextEditingController edtSearch = TextEditingController();
  List<LabTest> loadedlist = [];
  int loadedpage = 1, loadedoffset = 0;
  List<LabTest> searchResult = [];

  @override
  void initState() {
    super.initState();
    searchResult = [];

    setupScrollController(context);
    isFromSearch = widget.labid!.trim() == "0";
    print("labid=>${widget.labid}==$isFromSearch");

    if (widget.labTestList == null &&
        context.read<LabTestCubit>().state is! LabTestSuccess) {
      loadPage();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadPage({bool isSetInitial = false, Map<String, String>? parameter}) {
    parameter ??= {};
    if (widget.labid != null && widget.labid != "0") {
      parameter[ApiParams.labId] = widget.labid!;
    }
    print("currpage=${context.read<LabTestCubit>().offset}==$isSetInitial");

    context
        .read<LabTestCubit>()
        .getLabTestList(context, parameter, isSetInitial: isSetInitial);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        print(
            "loadedlistlength=>back**=====${loadedlist.length}==${edtSearch.text.trim().isNotEmpty}");
        if (edtSearch.text.trim().isNotEmpty) {
          print("loadedlistlength=>back**=call");
          setAllList();
        }
        return Future.value(true);
      },
      child: Scaffold(
        appBar: GeneralWidgets.setAppbar(getLables(lblBookLabTest), context),
        bottomNavigationBar:
            isFromSearch && selectedTestIds.isEmpty ? null : btnBtnWidget(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: widget.labTestList == null
              ? BlocBuilder<LabTestCubit, LabTestState>(
                  builder: (context, state) {
                    print("loadstate===****state//$state");
                    return mainContentWidget(state);
                  },
                )
              : mainContentWidget(null),
        ),
      ),
    );
  }

  mainContentWidget(LabTestState? state) {
    return Column(children: [
      GeneralWidgets.searchWidget(edtSearch, context, getLables(lblSearch),
          onSearchTextChanged: onSearchTextChanged),
      Expanded(child: headListWidget(state))
    ]);
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

  loadTestListData() {
    if (widget.labCubit != null && isChange) {
      widget.labCubit!.loadPosts(
          context, {ApiParams.testId: selectedTestIds.keys.join(",")},
          isSetInitial: true);
    }
  }

  btnBtnWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: lightGrey, blurRadius: 25.0, offset: Offset(0, -10))
        ],
      ),
      child: GeneralWidgets.btnWidget(
          context, getLables(isFromSearch ? lblCheckLabs : lblDone),
          callback: () {
        if (edtSearch.text.trim().isNotEmpty) {
          print("loadedlistlength=>back**=call");
          setAllList();
        }
        loadTestListData();
        Navigator.of(context).pop(isChange);
      }),
    );
  }

  contentWidget(LabTestState state) {
    print("state->$state");

    if (state is LabTestProgress && state.isFirstFetch) {
      return GeneralWidgets.loadingIndicator();
    } else if (state is LabTestFailure) {
      return GeneralWidgets.msgWithTryAgain(
          state.errorMessage, () => loadPage(isSetInitial: true));
    }

    return listContent(state);
  }
  /*return BlocBuilder<LabTestCubit, LabTestState>(
      builder: (context, state) {
        if (state is LabTestProgress) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is LabTestFailure) {
          return GeneralWidgets.msgWithTryAgain(
              state.errorMessage, () => getData());
        } else if (state is LabTestSuccess) {
          mainList.clear();
          mainList.addAll(state.labTestList);
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                GeneralWidgets.searchWidget(
                    edtSearch, context, getLables(lblSearch),
                    onSearchTextChanged: onSearchTextChanged),
                Expanded(child: headListWidget())
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }*/

  listContent(LabTestState state) {
    List<LabTest> posts = [];
    bool isLoading = false;
    int currpage = 1;
    int curroffset = 0;
    if (state is LabTestProgress) {
      posts = state.labTestList;
      isLoading = true;
      currpage = state.currPage;
      curroffset = state.currOffset;
    } else if (state is LabTestSuccess) {
      posts = state.labTestList;
      currpage = state.currPage;
      curroffset = state.currOffset;
    }

    if (edtSearch.text.trim().isEmpty && posts.isNotEmpty) {
      loadedpage = currpage;
      loadedoffset = curroffset;
      loadedlist = [];
      loadedlist = posts;
    }
    print("loadedlistlength=>${loadedlist.length}");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (posts.isNotEmpty)
          Text(
            getLables(lblAllTest),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsetsDirectional.only(top: 8),
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) {
            return const SizedBox(height: 8);
          },
          itemBuilder: (context, index) {
            if (index < posts.length)
              return itemWidget(posts[index]);
            else {
              Timer(Duration(milliseconds: 30), () {
                scrollController
                    .jumpTo(scrollController.position.maxScrollExtent);
              });

              return GeneralWidgets.loadingIndicator();
            }
          },
          itemCount: posts.length + (isLoading ? 1 : 0),
        ),
      ],
    );
  }

  headListWidget(LabTestState? state) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.all(4),
      child: Column(children: [
        if (selectedTestIds.isNotEmpty) seletedTestWidget(),
        state == null ? detailListWidget() : contentWidget(state),
      ]),
    );
  }

  detailListWidget() {
    List<LabTest> listContent = [];
    if (searchResult.isNotEmpty || edtSearch.text.trim().isNotEmpty) {
      listContent.addAll(searchResult);
    } else {
      listContent.addAll(widget.labTestList!);
    }
    print("listsize--${listContent.length}");
    if (listContent.isEmpty) {
      return Center(child: Text(getLables(dataNotFoundErrorMessage)));
    }
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getLables(lblAllTest),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          selectedItemList(listContent),
          const SizedBox(height: 20),
        ]);
  }

  seletedTestWidget() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getLables(lblSelectedTest),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          selectedItemList(selectedTestIds.values.toList()),
          const SizedBox(height: 20),
        ]);
  }

  /*cubitList() {
    List<LabTest> listContent = [];
    if (searchResult.isNotEmpty || edtSearch.text.trim().isNotEmpty) {
      listContent.addAll(searchResult);
    } else {
      listContent.addAll(mainList);
    }
    print("listsize--${listContent.length}");
    if (listContent.isEmpty) {
      return Center(child: Text(getLables(dataNotFoundErrorMessage)));
    }
    return listWidget(listContent);
  }*/

  itemWidget(LabTest labtest) {
    print("id=>${labtest.id}==${labtest.test}");

    return GeneralWidgets.cardBoxWidget(
      celevation: 0,
      cradius: 5,
      cmargin: EdgeInsetsDirectional.zero,
      childWidget: GeneralWidgets.setListtileMenu(
        labtest.test!,
        context,
        trailingwidget: Icon(
          selectedTestIds.containsKey(labtest.id)
              ? Icons.check_circle
              : Icons.radio_button_off,
          color: selectedTestIds.containsKey(labtest.id) ? primaryColor : grey,
        ),
        discwidget: isFromSearch
            ? null
            : RichText(
                text: TextSpan(
                    text: "${labtest.labAmount} ${Constant.currencyCode}\t\t\t",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .apply(color: primaryColor),
                    children: [
                    if (labtest.offerprice! > 0)
                      TextSpan(
                        text: "${labtest.offerprice} ${Constant.currencyCode}",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: grey,
                            fontWeight: FontWeight.w500,
                            decorationStyle: TextDecorationStyle.solid,
                            decoration: TextDecoration.lineThrough),
                      ),
                  ])),
        isdence: false,
        textStyle: Theme.of(context).textTheme.titleMedium!,
        onClickAction: () {
          isChange = true;
          if (selectedTestIds.containsKey(labtest.id)) {
            selectedTestIds.remove(labtest.id);
          } else {
            selectedTestIds[labtest.id!] = labtest;
          }
          setState(() {});
        },
      ),
    );
  }

  selectedItemList(List<LabTest> listContent) {
    return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: listContent.length,
        separatorBuilder: (context, index) {
          return const SizedBox(height: 8);
        },
        itemBuilder: (context, i) {
          LabTest labtest = listContent[i];
          print("id=>${labtest.id}");

          return itemWidget(labtest);
        });
  }

  onSearchTextChanged(String text) async {
    if (widget.labTestList != null) {
      searchResult.clear();
      if (text.trim().isEmpty) {
        setState(() {});
        return;
      }

      for (var userDetail in widget.labTestList!) {
        if (userDetail.test!
            .trim()
            .toLowerCase()
            .contains(text.trim().toLowerCase())) searchResult.add(userDetail);
      }

      setState(() {});
    } else {
      if (text.trim().isEmpty) {
        // setState(() {});
        print("emptry-search");
        setAllList();
        return;
      }

      loadPage(isSetInitial: true, parameter: {ApiParams.search: text});
    }
  }

  setAllList() {
    print(
        "Lab==loadedlistlength=>=====${loadedlist.length}===${widget.labTestList == null}");
    if (widget.labTestList == null) {
      context
          .read<LabTestCubit>()
          .setOldList(loadedoffset, loadedpage, loadedlist);
    }
  }
}
