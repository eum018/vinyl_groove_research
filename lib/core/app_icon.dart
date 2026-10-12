import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

enum AppIcon {
  edit('edit.svg'),
  finger('finger-print.svg'),
  help('help.svg'),
  history('history.svg'),
  info('info.svg'),
  inventory('inventory.svg'),
  pin('pin-number-pad.svg'),
  shopping('shopping-bag.svg'),
  delete('delete.svg'),
  add('add.svg'),
  album('album.svg'),
  barcode('barcode-scan.svg'),
  chevron('chevron-right.svg'),
  classical('classical.svg'),
  electronic('electronic.svg'),
  email('email.svg'),
  etc('etc.svg'),
  heart('heart.svg'),
  hip('hip-hop.svg'),
  home('home.svg'),
  jazz('jazz.svg'),
  lock('lock.svg'),
  mypage('mypage.svg'),
  notification('notification.svg'),
  person('person.svg'),
  pop('pop.svg'),
  rnb('rnb-soul.svg'),
  rock('rock.svg'),
  search('search.svg'),
  visibility('visibility.svg'),
  visibilityoff('visibility-off.svg');

  const AppIcon(this.file);

  final String file;

  SvgPicture icon({Color? color, double? size}) => SvgPicture.asset(
    'assets/icons/$file',
    width: size,
    height: size,
    colorFilter: color == null
        ? null
        : ColorFilter.mode(color, BlendMode.srcIn),
  );
}
