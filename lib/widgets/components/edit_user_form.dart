import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../models/index.dart';
import '../../utils/index.dart';
import '../../widgets/screens/index.dart';
import 'custom_circle_avatar.dart';
import 'custom_divider.dart';
import 'custom_text_form_field.dart';

class EditUserForm extends StatefulWidget {
  const EditUserForm({
    @required Key key,
    @required this.initialValue,
  }) : super(key: key);

  final AppUser initialValue;

  @override
  EditUserFormState createState() => EditUserFormState();
}

class EditUserFormState extends State<EditUserForm> {
  TextEditingController _displayNameController;
  TextEditingController _biographyController;
  UserAvatar _avatar;
  Weapon _mainWeapon;
  MonsterHunterSeries _firstPlayedSeries;

  static const _displayNameMaxLength = 20;
  static const _biographyMaxLength = 100;

  AppUser get() {
    return AppUser(
      displayName: _displayNameController.text,
      biography: _biographyController.text,
      avatar: _avatar,
      mainWeapon: _mainWeapon,
      firstPlayedSeries: _firstPlayedSeries,
    );
  }

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.initialValue?.displayName ?? '',
    );
    _biographyController = TextEditingController(
      text: widget.initialValue?.biography ?? '',
    );
    _avatar = widget.initialValue?.avatar;
    _mainWeapon = widget.initialValue?.mainWeapon;
    _firstPlayedSeries = widget.initialValue?.firstPlayedSeries;
  }

  @override
  void dispose() {
    super.dispose();
    _displayNameController.dispose();
    _biographyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomCircleAvatar(
          filePath: _avatar?.iconFilePath,
          radius: 50,
          onTap: () async {
            final result = await Navigator.pushNamed(
              context,
              SelectAvatarScreen.route,
            ) as UserAvatar;
            if (result != null) {
              if (mounted) {
                setState(() {
                  _avatar = result;
                });
              }
            }
          },
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              CustomTextFormField(
                labelText: 'ユーザー名',
                controller: _displayNameController,
                maxLength: _displayNameMaxLength,
                validator: _displayNameValidator,
              ),
              const SizedBox(height: 30),
              CustomTextFormField(
                labelText: '自己紹介',
                hintText: 'よろしくお願いします！',
                controller: _biographyController,
                maxLength: _biographyMaxLength,
                maxLines: 6,
                validator: _biographyValidator,
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        CustomDivider(),
        _selectMainWeaponCell(),
        CustomDivider(),
        _selectFirstPlayedSeriesCell(),
        CustomDivider(),
      ],
    );
  }

  Widget _selectMainWeaponCell() {
    return Material(
      color: AppColors.grey20,
      child: InkWell(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 15),
                child: const Text('メイン武器'),
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _mainWeapon != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Image.asset(
                                _mainWeapon.iconFilePath,
                                width: 45,
                                height: 45,
                              ),
                              const SizedBox(width: 5),
                              Text(_mainWeapon.name),
                            ],
                          )
                        : const Text(
                            '選択してください',
                            style: TextStyle(color: AppColors.grey60),
                          ),
                    const SizedBox(width: 5),
                    const Icon(Icons.chevron_right_sharp),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () async {
          final result = await Navigator.pushNamed(
            context,
            SelectWeaponScreen.route,
          ) as Weapon;
          if (result != null) {
            if (mounted) {
              setState(() {
                _mainWeapon = result;
              });
            }
          }
        },
      ),
    );
  }

  Widget _selectFirstPlayedSeriesCell() {
    return Material(
      color: AppColors.grey20,
      child: InkWell(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 15),
                margin: const EdgeInsets.only(right: 15),
                child: const Text('初プレイシリーズ'),
              ),
              Flexible(
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: _firstPlayedSeries != null
                            ? AutoSizeText(
                                _firstPlayedSeries.name,
                                textAlign: TextAlign.right,
                                maxLines: 1,
                              )
                            : const Text(
                                '選択してください',
                                style: TextStyle(color: AppColors.grey60),
                              ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.chevron_right_sharp),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () async {
          final result = await Navigator.pushNamed(
            context,
            SelectMonsterHunterSeriesScreen.route,
          ) as MonsterHunterSeries;
          if (result != null) {
            if (mounted) {
              setState(() {
                _firstPlayedSeries = result;
              });
            }
          }
        },
      ),
    );
  }

  String _displayNameValidator(String displayName) {
    final errorMessages = <String>[]
      ..add(Validations.blank(displayName))
      ..add(Validations.maxLength(displayName, _displayNameMaxLength));

    for (final errorMessage in errorMessages) {
      if (errorMessage != null) {
        return errorMessage;
      }
    }
    return null;
  }

  String _biographyValidator(String biography) {
    final errorMessages = <String>[]
      ..add(Validations.blank(biography))
      ..add(Validations.maxLength(biography, _biographyMaxLength));

    for (final errorMessage in errorMessages) {
      if (errorMessage != null) {
        return errorMessage;
      }
    }
    return null;
  }
}
