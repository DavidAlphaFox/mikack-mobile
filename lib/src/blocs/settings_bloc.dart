import 'package:bloc/bloc.dart';
import 'package:extended_image/extended_image.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_event.dart';
import 'settings_state.dart';
import '../values.dart';
import '../models.dart';
import '../../store.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  @override
  SettingsState get initialState => SettingsLoadedSate(
        startPage: StartPageItem(vDefaultPage),
        allowNsfw: false,
        chaptersReversed: false,
        leftHand: false,
        readingMode: ReadingModeItem(vLeftToRight),
        cachedImageSize: 0,
      );

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    switch (event.runtimeType) {
      case SettingsRequestEvent: // 请求设置数据
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // 读取：开始页面
        var startPageKey = prefs.getString(kStartPageKey);
        StartPageItem startPage;
        if (startPageKey != null) startPage = StartPageItem(startPageKey);
        // 读取：允许 NSFW
        var allowNsfw = prefs.getBool(allowNsfwKey);
        // 读取：反转章节列表
        var chaptersReversed = prefs.getBool(chaptersReversedKey);
        // 读取：阅读模式
        var readingModeKey = prefs.getString(kReadingMode);
        ReadingModeItem readingMode;
        if (readingModeKey != null)
          readingMode = ReadingModeItem(readingModeKey);
        // 读取：左手翻页
        var leftHand = prefs.getBool(vLeftHandModeKey);
        // 读取：历史记录数量
        var historiesTotal = await getHistoriesTotal();
        // 读取：书架收藏数量
        var favoritesTotal = await getFavoritesTotal();
        // 读取：缓存大小
        var cachedImageSize = await getCachedSizeBytes() / 1024 / 1024;
        // 读取：版本信息
        var packageInfo = await PackageInfo.fromPlatform();

        yield (state as SettingsLoadedSate).copyWith(
          startPage: startPage,
          allowNsfw: allowNsfw,
          chaptersReversed: chaptersReversed,
          leftHand: leftHand,
          readingMode: readingMode,
          cachedImageSize: cachedImageSize,
          historiesTotal: historiesTotal,
          favoritesTotal: favoritesTotal,
          packageInfo: packageInfo,
        );
        break;
      case SettingsStartPageChangedEvent: // 开始页面变更
        var castedEvent = event as SettingsStartPageChangedEvent;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(kStartPageKey, castedEvent.startPage.key);

        yield (state as SettingsLoadedSate)
            .copyWith(startPage: castedEvent.startPage);
        break;
      case ReadingModeChangedEvent: // 阅读模式变更
        var castedEvent = event as ReadingModeChangedEvent;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(kReadingMode, castedEvent.readingMode.key);

        yield (state as SettingsLoadedSate)
            .copyWith(readingMode: castedEvent.readingMode);
        break;
      case SettingsSwitchedEvent: // 开关类型的设置变更
        var castedEvent = event as SettingsSwitchedEvent;
        var castedState = state as SettingsLoadedSate;
        var changedValue = castedEvent.changedValue;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        switch (castedEvent.switchType) {
          case SettingsSwitchType.leftHand: // 左手模式
            await prefs.setBool(vLeftHandModeKey, changedValue);
            yield castedState.copyWith(leftHand: changedValue);
            break;
          case SettingsSwitchType.allowNsfw: // 允许 NSFW
            await prefs.setBool(allowNsfwKey, changedValue);
            yield castedState.copyWith(allowNsfw: changedValue);
            break;
          case SettingsSwitchType.reverseChapters: // 反转章节列表
            await prefs.setBool(chaptersReversedKey, changedValue);
            yield castedState.copyWith(chaptersReversed: changedValue);
            break;
        }
        break;
      case SettingsCleanupRequestEvent: // 数据清空
        final castedEvent = event as SettingsCleanupRequestEvent;
        final castedState = state as SettingsLoadedSate;
        switch (castedEvent.cleanupType) {
          case SettingsCleanupType.histories: // 历史
            await deleteAllHistories();
            yield castedState.copyWith(historiesTotal: 0);
            break;
          case SettingsCleanupType.favorites: // 收藏
            await deleteAllFavorites();
            yield castedState.copyWith(favoritesTotal: 0);
            break;
          case SettingsCleanupType.cachedImages: // 缓存的图片
            clearMemoryImageCache();
            await clearDiskCachedImages();
            yield castedState.copyWith(cachedImageSize: 0.0);
            break;
        }
        break;
    }
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    print(stacktrace);
    super.onError(error, stacktrace);
  }
}
