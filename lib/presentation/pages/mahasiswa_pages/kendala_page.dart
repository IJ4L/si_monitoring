import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simor/cubit/get_komen_cubit/getkomen_cubit.dart';
import 'package:simor/cubit/mahasiswa_cubit/mahasiswa_cubit.dart';
import 'package:simor/cubit/post_komen/post_komen_cubit.dart';
import 'package:simor/cubit/texfield_cubit.dart';
import 'package:simor/models/komen_model.dart';
import 'package:simor/presentation/widgets/costume_button.dart';
import 'package:simor/shared/themes.dart';

import '../../widgets/costume_dialog.dart';

class KendalaMahasiswa extends StatefulWidget {
  const KendalaMahasiswa({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _KendalaMahasiswaState createState() => _KendalaMahasiswaState();
}

class _KendalaMahasiswaState extends State<KendalaMahasiswa> {
  late TextEditingController kendalaController;
  final TextEditingController feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<MahasiswaCubit>().cekKendala();
    kendalaController = TextEditingController();
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final kendalaCubit = context.read<MahasiswaCubit>();
    final textFieldCubit = context.read<TextfieldCubit>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(242, 255, 255, 255),
      appBar: buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () {
          return context.read<GetkomenCubit>().getKomen();
        },
        child: buildBody(kendalaCubit, textFieldCubit),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  PreferredSizeWidget buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(130.h),
      child: Container(
        height: 130.h,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage("assets/images/backgorund.png"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25.w)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home-mahasiswa',
                    (route) => false,
                  );
                },
                child: const Icon(
                  Icons.arrow_back_outlined,
                  color: Colors.white,
                ),
              ),
              Image.asset(
                "assets/images/logo.png",
                height: 40.h,
                width: 180.w,
                fit: BoxFit.cover,
              ),
              const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBody(MahasiswaCubit kendalaCubit, TextfieldCubit textFieldCubit) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildKendalaRow(kendalaCubit),
          buildKendalaTextField(kendalaCubit, textFieldCubit),
          buildKirimButton(kendalaCubit, textFieldCubit),
          buildListKomen(),
        ],
      ),
    );
  }

  Widget buildListKomen() {
    return Expanded(
      child: BlocBuilder<GetkomenCubit, GetkomenState>(
        builder: (context, state) {
          if (state is GetkomenLoading) {
            return SizedBox(
              height: 10.h,
              width: double.infinity,
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 10.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            );
          }
          if (state is GetkomenLoaded) {
            final data = state.komen;
            return ListView.separated(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return buildListKomenItem(data[index]);
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 10);
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget buildListKomenItem(KomenModel komen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                komen.author,
                style: const TextStyle(color: kTextInfoColor, fontSize: 10),
              ),
              const Spacer(),
              Text(
                "${komen.createdAt}",
                style: const TextStyle(color: kTextInfoColor, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Text(
            komen.deskripsi,
            style: blackTextStyle.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: kTextInfoColor,
            ),
            textScaleFactor: 1,
          ),
        ],
      ),
    );
  }

  Widget buildKendalaRow(MahasiswaCubit kendalaCubit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Kendala:',
          style: blackTextStyle.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: kTextInfoColor,
          ),
          textScaleFactor: 1,
        ),
        BlocBuilder<MahasiswaCubit, MahasiswaState>(
          builder: (context, state) {
            if (state is MahasiswaGetKendala) {
              final data = state.kendala;
              final isAccepted = data.status != 0;
              return buildStatusContainer(isAccepted);
            }
            return Container();
          },
        ),
      ],
    );
  }

  Widget buildStatusContainer(bool isAccepted) {
    return Container(
      height: 24.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: isAccepted ? kGreenColor : kSecondColor,
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(
            "assets/icons/clock.svg",
            height: 10.r,
            width: 10.r,
            fit: BoxFit.fill,
          ),
          SizedBox(width: 8.w),
          Text(
            isAccepted ? 'Diterima' : 'Belum diterima',
            style: whiteTextStyle.copyWith(fontSize: 10.sp),
            textScaleFactor: 1,
          ),
        ],
      ),
    );
  }

  Widget buildKendalaTextField(
      MahasiswaCubit kendalaCubit, TextfieldCubit textFieldCubit) {
    return BlocConsumer<MahasiswaCubit, MahasiswaState>(
      listener: (context, state) {
        if (state is MahasiswaGetKendala) {
          kendalaController.text = state.kendala.deskripsi;
        }
      },
      builder: (context, state) {
        if (state is MahasiswaGetKendala) {
          return buildKendalaContainer();
        }
        return buildDefaultKendalaTextField();
      },
    );
  }

  Widget buildKendalaContainer() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: 210.h,
          width: double.infinity,
          padding: EdgeInsets.all(10.h),
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              TextFormField(
                controller: kendalaController,
                maxLines: 7,
                cursorColor: kBlackColor,
                readOnly: true,
                style: TextStyle(color: kGreyColor.withOpacity(0.6)),
                decoration: buildInputDecoration(),
              ),
              const Spacer(),
              buildFeedbackContainer(),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration buildInputDecoration() {
    return InputDecoration(
      floatingLabelBehavior: FloatingLabelBehavior.never,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: kTransparantColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: kTransparantColor),
      ),
    );
  }

  Widget buildFeedbackContainer() {
    return GestureDetector(
      onTap: () {
        buildFeedbackBottomSheet();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kGreyColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          "Berikan feedback kepada Dosen ...",
        ),
      ),
    );
  }

  void buildFeedbackBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      builder: (BuildContext context) {
        return buildBottomSheetContainer();
      },
    );
  }

  Widget buildBottomSheetContainer() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: 270.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextFormField(
                  controller: feedbackController,
                  cursorColor: kBlackColor,
                  style: const TextStyle(color: kBlackColor),
                  keyboardType: TextInputType.multiline,
                  maxLines: 8,
                  decoration: buildFeedbackInputDecoration(),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Feedback tidak boleh kosong';
                    }
                    return "";
                  },
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(left: 200),
                  child: Costumebutton(
                    title: "Kirim",
                    ontap: () {
                      if (kendalaController.text.isNotEmpty) {
                        Navigator.pop(context);
                        context
                            .read<PostKomenCubit>()
                            .postKomen(feedbackController.text);
                        context.read<GetkomenCubit>().getKomen();
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration buildFeedbackInputDecoration() {
    return InputDecoration(
      hintText: 'Berikan feedback ...',
      hintStyle: TextStyle(
        color: kGreyColor.withOpacity(0.4),
        fontStyle: FontStyle.italic,
        fontSize: 12.sp,
      ),
      fillColor: kGreyColor.withOpacity(0.2),
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: kTransparantColor),
        borderRadius: BorderRadius.circular(16.r),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: kTransparantColor),
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }

  Widget buildDefaultKendalaTextField() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20.h),
            child: TextFormField(
              controller: kendalaController,
              cursorColor: kBlackColor,
              style: const TextStyle(color: kBlackColor),
              keyboardType: TextInputType.multiline,
              maxLines: 8,
              decoration: buildInputDecorationWithBorders(kTextInfoColor),
            ),
          ),
          buildTextFieldErrorMessage(),
        ],
      ),
    );
  }

  InputDecoration buildInputDecorationWithBorders(Color borderColor) {
    return InputDecoration(
      hintText: 'Deskripsikan Rencana Kegiatanmu Hari Ini',
      hintStyle: TextStyle(
        color: kGreyColor.withOpacity(0.4),
        fontStyle: FontStyle.italic,
        fontSize: 12.sp,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: kRedColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: kRedColor),
      ),
    );
  }

  Widget buildTextFieldErrorMessage() {
    return Padding(
      padding: EdgeInsets.only(top: 6.h, bottom: 10.h, left: 10.w),
      child: BlocBuilder<TextfieldCubit, bool>(
        builder: (context, state) {
          return Text(
            state ? '' : 'Masukkan Kendala',
            style: whiteTextStyle.copyWith(color: kRedColor),
          );
        },
      ),
    );
  }

  Widget buildKirimButton(
      MahasiswaCubit kendalaCubit, TextfieldCubit textFieldCubit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(),
        BlocBuilder<MahasiswaCubit, MahasiswaState>(
          builder: (context, state) {
            if (state is MahasiswaGetKendala) {
              context.read<GetkomenCubit>().getKomen();
              return Container();
            }
            return buildKirimButtonContainer(kendalaCubit, textFieldCubit);
          },
        ),
      ],
    );
  }

  Widget buildKirimButtonContainer(
      MahasiswaCubit kendalaCubit, TextfieldCubit textFieldCubit) {
    return Container(
      height: 40.h,
      width: (MediaQuery.of(context).size.width / 2.6),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: kPrimaryColor),
      ),
      child: Material(
        color: kTransparantColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(8.w),
          onTap: () {
            textFieldCubit.checkTextfield(kendalaController.text);
            if (textFieldCubit.state) {
              kendalaCubit.kirimKendala(kendalaController.text);
              kendalaCubit.cekKendala();
              showDialog<void>(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return const Dialoginfo(
                    height: 320,
                    title: 'Kendala kegiatan\nberhasil di simpan',
                  );
                },
              );
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Kirim',
                style: TextStyle(
                  color: kWhiteColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                ),
                textScaleFactor: 1,
              )
            ],
          ),
        ),
      ),
    );
  }
}
