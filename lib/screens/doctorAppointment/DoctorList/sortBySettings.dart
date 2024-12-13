import 'package:flutter/material.dart';
import 'package:tabebi/helper/apiParams.dart';
import 'package:tabebi/helper/colors.dart';
import 'package:tabebi/helper/constant.dart';
import 'package:tabebi/helper/generalMethods.dart';
import 'package:tabebi/helper/stringLables.dart';
import '../../../cubits/doctor/doctorCubit.dart';

class SortBySettings extends StatelessWidget {
  final DoctorCubit doctorCubit;
  const SortBySettings({Key? key, required this.doctorCubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String selectedvalue =
        Constant.drGetListParams[ApiParams.sort] ?? Constant.drNoSortyByValue;
    print("sval=$selectedvalue");
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(
              getLables(lblSortBy),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .apply(color: primaryColor),
            ),
            Spacer(),
            if (selectedvalue != Constant.drNoSortyByValue)
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Constant.drGetListParams[ApiParams.sort] =
                        Constant.drNoSortyByValue;
                    doctorCubit.loadPosts(context, Constant.drGetListParams,
                        isSetInitial: true);
                  },
                  child: Text(getLables(lblClear),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .apply(color: grey)))
          ]),
          Divider(
            color: lightGrey,
            height: 40,
          ),
          Wrap(
              children: List.generate(
                  Constant.doctorSortByList.length,
                  (index) => RadioListTile(
                      title: Text(Constant.doctorSortByList[index]["title"]),
                      value: Constant.doctorSortByList[index]["id"],
                      groupValue: selectedvalue,
                      controlAffinity: ListTileControlAffinity.trailing,
                      onChanged: (value) {
                        if (selectedvalue != value) {
                          Navigator.of(context).pop();
                          Constant.drGetListParams[ApiParams.sort] = value;
                          doctorCubit.loadPosts(
                              context, Constant.drGetListParams,
                              isSetInitial: true);
                        }
                      })))
        ]);
  }
}
