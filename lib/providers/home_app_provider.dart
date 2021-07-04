import 'dart:io';

import 'package:aplikasi_antrian/configs/constants/view_state.dart';
import 'package:aplikasi_antrian/locator.dart';
import 'package:aplikasi_antrian/models/detail_histori_antrian_model.dart';
import 'package:aplikasi_antrian/providers/base_provider.dart';
import 'package:aplikasi_antrian/services/antrian_service.dart';

class HomeAppProvider extends BaseProvider{
  AntrianService _antrianService = locator<AntrianService>();
  Future getDetailAntrian({String idAntrian}) async{
    try {
      DetailHistoriAntrianModel detailHistoriAntrianModel = await _antrianService.getDetailHistoriAntrian(idAntrian: idAntrian);
      return detailHistoriAntrianModel;
    } on SocketException catch(_){
      setState(ViewState.ErrConnection);
      return null;
    }
    catch (e) {
      print(e);
      if(e == 404 || e == 502 || e == 503){
        setState(ViewState.ErrConnection);
      }
      return null;
    }
  }
}