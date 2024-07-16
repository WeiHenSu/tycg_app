import 'package:flutter/material.dart';

const BASE_URL = 'https://tycg.m2x.com.tw/master_cms';

const CONSTRUCTION_ASSETS = '/assets/construction/';
const ROUND_ASSETS = '/assets/round/';

///資料存取令牌
const String ACCESS_TOKEN = 'access_token';

///資料更新令牌
const String REFRESH_TOKEN = 'refresh_token';

///Hive
///應用程式狀態儲存槽
const String BOX_APPLICATION_STATE = 'applicatio_state';

///儲存hive box金鑰
const String SECURE_STORAGE_KEY = 'storage_key';

///資料儲存槽
const String BOX_SECURITY_DATA = 'security_data';

///授權儲存槽
const String BOX_AUTH_CODE = 'auth_code';

///暫存資料儲存槽
const String BOX_CACHE = 'cache_data';

///裝置id
const String DEVICE_ID = 'device_id';

///裝置版本
const String DEVICE_VERSION = 'device_version';

///裝置型號
const String DEVICE_MODEL = '';

///巡檢資料
const String ROUND_DATA = 'round_data';

///巡檢作業項目
const String OPERATION_IDS = 'operation_ids';

///巡檢缺失資料
const String LACK_DATA = 'lack_data';

///作業項目資料
const String OPERATION_DATA = 'operation_data';

///缺失類型資料
const String LACKTYPE_DATA = 'lacktype_data';

///媒介物資料
const String TERTIARY_DATA = 'tertiary_data';

///缺失內容資料
const String LACKCONTENT_DATA = 'lackcontent_data';

//最後取得資料時間
const String LAST_UPDATETIME = 'last_updatetime';

///認證失效
const String INVALID_AUTHENTICATION = 'invalid authentication';
