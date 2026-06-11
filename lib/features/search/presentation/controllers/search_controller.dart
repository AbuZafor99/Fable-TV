import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

import '../../../../core/utils/debug_print.dart';
import '../../../home/data/models/channel_model.dart';
import '../../../home/data/models/country_model.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../domain/repository/search_repository.dart';

class SearchController extends GetxController {
  final SearchRepository _searchRepository = Get.find();
  final HomeController _homeController = Get.find();

  final TextEditingController searchTf = TextEditingController();
  final RxString query = ''.obs;
  final RxList<ChannelModel> searchResults = <ChannelModel>[].obs;
  final RxList<ChannelModel> mapResults = <ChannelModel>[].obs;
  final RxString selectedCountryCode = ''.obs;
  final RxString selectedCountryName = ''.obs;
  final RxList<String> activeFilterCategories = <String>[].obs;
  final RxString activeFilterCountry = ''.obs;
  final RxBool isSearching = false.obs;
  final RxBool showMapResults = false.obs;

  List<CountryModel> get countries => _homeController.countries;
  Map<String, int> get channelCountByCountry =>
      _homeController.channelCountByCountry;

  bool get hasActiveFilters =>
      activeFilterCategories.isNotEmpty || activeFilterCountry.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    debounce(query, (_) => _runSearch(),
        time: const Duration(milliseconds: 400));
  }

  void onQueryChanged(String value) {
    query.value = value;
  }

  Future<void> _runSearch() async {
    if (query.value.trim().isEmpty && !hasActiveFilters) {
      searchResults.clear();
      return;
    }
    isSearching.value = true;
    try {
      searchResults.assignAll(await _searchRepository.searchChannels(
        query: query.value,
        categories: activeFilterCategories,
        country: activeFilterCountry.value,
      ));
    } finally {
      isSearching.value = false;
    }
  }

  /// Pin taps resolve the country directly.
  Future<void> onCountryPinTap(CountryModel country) =>
      _selectCountry(country.code, country.name);

  /// Background map taps: reverse-geocode, falling back to the nearest
  /// hardcoded centroid when geocoding is unavailable (offline).
  Future<void> onMapTap(double lat, double lng) async {
    String? code;
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      code = placemarks.isNotEmpty
          ? placemarks.first.isoCountryCode?.toUpperCase()
          : null;
    } catch (e) {
      dPrint('Reverse geocoding failed, using centroid fallback: $e');
    }
    code ??= CountryModel.nearestCountryCode(lat, lng);
    if (code == null) return;
    final country = _homeController.countryByCode[code];
    await _selectCountry(code, country?.name ?? code);
  }

  Future<void> _selectCountry(String code, String name) async {
    selectedCountryCode.value = code;
    selectedCountryName.value = name;
    mapResults.assignAll(await _searchRepository.channelsByCountry(code));
    showMapResults.value = true;
  }

  void applyFilters(List<String> categories, String country) {
    activeFilterCategories.assignAll(categories);
    activeFilterCountry.value = country;
    _runSearch();
  }

  void clearFilters() {
    activeFilterCategories.clear();
    activeFilterCountry.value = '';
    _runSearch();
  }

  void clearMapSelection() {
    showMapResults.value = false;
    selectedCountryCode.value = '';
    selectedCountryName.value = '';
    mapResults.clear();
  }

  @override
  void onClose() {
    searchTf.dispose();
    super.onClose();
  }
}
