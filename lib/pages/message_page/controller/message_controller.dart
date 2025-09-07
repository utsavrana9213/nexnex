import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Wow/pages/message_page/api/fetch_message_user_api.dart';
import 'package:Wow/pages/message_page/api/search_message_user_api.dart';
import 'package:Wow/pages/message_page/model/fetch_message_user_model.dart';
import 'package:Wow/pages/message_page/model/search_message_user_model.dart';
import 'package:Wow/utils/database.dart';
import 'package:Wow/utils/utils.dart';

class MessageController extends GetxController {
  bool isLoading = false;
  List<Data> messageUsers = [];
  FetchMessageUserModel? fetchMessageUserModel;

  bool isPaginationLoading = false;
  ScrollController scrollController = ScrollController();

  int messageRequestCount = 0;

  Future<void> init() async {
    isLoading = true;
    isPaginationLoading = false;
    messageUsers.clear();
    FetchMessageUserApi.startPagination = 0;
    onChangeSearchHistory(false);
    filterDeletedChats();
    update(["onGetMessageUsers"]);
    await onGetMessageUsers();
    searchMessageUserHistory.clear();
    searchMessageUserHistory.addAll(Database.searchMessageUserHistory);
    scrollController.addListener(onPagination);
  }

  // >>>>> >>>>> >>>>> Get Message User <<<<< <<<<< <<<<<

  Future<void> onGetMessageUsers() async {
    fetchMessageUserModel = await FetchMessageUserApi.callApi(loginUserId: Database.loginUserId);

    if (fetchMessageUserModel?.data != null && (fetchMessageUserModel?.data?.isNotEmpty ?? false)) {
      final paginationData = fetchMessageUserModel?.data ?? [];

      Utils.showLog("Message User => Page Index : ${FetchMessageUserApi.startPagination} Length : ${paginationData.length}");

      if (FetchMessageUserApi.startPagination == 1) {
        messageUsers.clear();
      }

      // Filter out deleted chats before adding to the list
      final filteredData = paginationData
          .where((user) => !Database.isChatDeleted(user.userId ?? ""))
          .toList();

      messageUsers.addAll(filteredData);

      messageRequestCount = fetchMessageUserModel?.pendingCount ?? 0;

      update(["onGetMessageUsers"]);
    } else {
      FetchMessageUserApi.startPagination--;
    }

    if (isLoading) {
      isLoading = false;
      update(["onGetMessageUsers"]);
    }
  }

  Future<void> onPagination() async {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !isPaginationLoading) {
      isPaginationLoading = true;
      update(["onPagination"]);
      await onGetMessageUsers();
      isPaginationLoading = false;
      update(["onPagination"]);
    }
  }

  Future<void> onDispose() async {
    scrollController.removeListener(onPagination);
  }

  // >>>>> >>>>> >>>>> Search Message User <<<<< <<<<< <<<<<

  bool isSearching = false;

  bool isSearchingMessageUser = false;
  List<SearchUserData> searchMessageUsers = [];
  SearchMessageUserModel? searchMessageUserModel;

  TextEditingController searchController = TextEditingController();

  Future<void> onSearching() async {
    if (searchController.text.trim().isNotEmpty) {
      isSearching = true; // Show Search Data...
      update(["onSearching"]);
      onSearchMessageUser(searchController.text);
    } else if (searchController.text.isEmpty) {
      isSearching = false; // Show All Data...
      update(["onSearching"]);
    }
  }

  Future<void> onSearchMessageUser(String searchText) async {
    searchMessageUserModel = null;
    searchMessageUsers.clear();
    isSearchingMessageUser = true;
    update(["onSearchMessageUser"]);

    searchMessageUserModel = await SearchMessageUserApi.callApi(loginUserId: Database.loginUserId, searchText: searchText);
    if (searchMessageUserModel?.data != null) {
      searchMessageUsers.clear();
      // Filter out deleted chats from search results
      final filteredSearchData = searchMessageUserModel?.data
              ?.where((user) => !Database.isChatDeleted(user.id ?? ""))
              .toList() ??
          [];
      searchMessageUsers.addAll(filteredSearchData);
      isSearchingMessageUser = false;
      update(["onSearchMessageUser"]);
    }
  }

  // >>>>> >>>>> >>>>> Search User History <<<<< <<<<< <<<<<

  List searchMessageUserHistory = [];
  bool isShowSearchMessageUserHistory = false;

  void onChangeSearchHistory(bool value) {
    if (value) {
      if (searchMessageUserHistory.isNotEmpty) {
        isShowSearchMessageUserHistory = value;
        update(["onChangeSearchHistory"]);
      }
    } else {
      isShowSearchMessageUserHistory = value;
      update(["onChangeSearchHistory"]);
    }
  }

  void onCreateSearchHistory() {
    if (searchController.text.trim().isNotEmpty && !searchMessageUserHistory.contains(searchController.text)) {
      searchMessageUserHistory.add(searchController.text);
      Database.onSetSearchMessageUserHistory(searchMessageUserHistory); // Add In Database
      update(["onChangeSearchHistory"]);
    }
  }

  void onDeleteSearchHistory(int index) {
    searchMessageUserHistory.removeAt(index);
    Database.onSetSearchMessageUserHistory(searchMessageUserHistory); // Reset Database
    update(["onChangeSearchHistory"]);
  }

  // >>>>> >>>>> >>>>> Remove Deleted Chat <<<<< <<<<< <<<<<

  void removeChatFromList(String userId) {
    messageUsers.removeWhere((chat) => chat.userId == userId);
    searchMessageUsers.removeWhere((chat) => chat.id == userId);
    update(["onGetMessageUsers"]);
    update(["onSearchMessageUser"]);
    Utils.showLog("Chat with user $userId removed from message list");
  }

  // >>>>> >>>>> >>>>> Filter Deleted Chats <<<<< <<<<< <<<<<

  void filterDeletedChats() {
    // Remove any deleted chats from the current list
    messageUsers
        .removeWhere((chat) => Database.isChatDeleted(chat.userId ?? ""));
    searchMessageUsers
        .removeWhere((chat) => Database.isChatDeleted(chat.id ?? ""));
    update(["onGetMessageUsers"]);
    update(["onSearchMessageUser"]);
    Utils.showLog("Filtered out deleted chats from message lists");
  }

// >>>>> >>>>> >>>>> Delete Chat <<<<< <<<<< <<<<<
}
