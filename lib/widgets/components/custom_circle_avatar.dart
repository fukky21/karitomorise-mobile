import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';

class CustomCircleAvatar extends StatelessWidget {
  const CustomCircleAvatar({@required this.avatarType, @required this.radius});

  final int avatarType;
  final double radius;

  @override
  Widget build(BuildContext context) {
    const _icons = _AvatarIcons.all;
    const _filePathFieldName = _AvatarIcons.filePathFieldName;

    Widget _image = Image.asset(_icons[0][_filePathFieldName] as String);
    if (avatarType != null) {
      if (1 <= avatarType && avatarType <= _icons.length - 1) {
        _image = Image.asset(_icons[avatarType][_filePathFieldName] as String);
      }
    }
    return CircularProfileAvatar(
      '',
      child: _image,
      borderColor: Theme.of(context).primaryColor,
      borderWidth: 2,
      radius: radius,
    );
  }
}

class _AvatarIcons {
  static const _rootPath = 'assets/icons/monsters';
  static const typeFieldName = 'type';
  static const filePathFieldName = 'file_path';

  // Unknown
  static const unknown = {
    typeFieldName: 0,
    filePathFieldName: '$_rootPath/unknown.png',
  };
  // アグナコトル
  static const agnaktor = {
    typeFieldName: 1,
    filePathFieldName: '$_rootPath/agnaktor.png',
  };
  // アカムトルム
  static const akantor = {
    typeFieldName: 2,
    filePathFieldName: '$_rootPath/akantor.png',
  };
  // アオアシラ
  static const arzuros = {
    typeFieldName: 3,
    filePathFieldName: '$_rootPath/arzuros.png',
  };
  // リオレウス亜種
  static const azureRathalos = {
    typeFieldName: 4,
    filePathFieldName: '$_rootPath/azure_rathalos.png',
  };
  // ギギネブラ亜種
  static const balefulGigginox = {
    typeFieldName: 5,
    filePathFieldName: '$_rootPath/baleful_gigginox.png',
  };

  static const all = [
    unknown,
    agnaktor,
    akantor,
    arzuros,
    azureRathalos,
    balefulGigginox,
  ];
}
