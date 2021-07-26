import 'dart:io';

import 'package:aplikasi_antrian/configs/themes/app_themes.dart';
import 'package:aplikasi_antrian/locator.dart';
import 'package:aplikasi_antrian/models/detail_histori_antrian_model.dart';
import 'package:aplikasi_antrian/presentations/views/antrian/detail_histori_antrian.dart';
import 'package:aplikasi_antrian/providers/home_app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeApp extends StatefulWidget {
  const HomeApp({Key key}) : super(key: key);

  @override
  _HomeAppState createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text("MPP Pekanbaru"),
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: ()async{
                showDialog(
                    context: context,
                    builder: (context){
                      return AlertDialog(
                        content: Text("Apakah anda yakin?"),
                        actions: [
                          FlatButton(
                            child: Text("Tidak"),
                            onPressed: (){
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: Text("Ya"),
                            onPressed: () async{
                              Navigator.pop(context);
                              EasyLoading.show(status: "Loading...", maskType: EasyLoadingMaskType.black, dismissOnTap: false);
                              SharedPreferences preferences = await SharedPreferences.getInstance();
                              preferences.clear();
                              EasyLoading.dismiss();
                              Navigator.pushNamedAndRemoveUntil(
                                  context, 'login', (route) => false);
                            },
                          )
                        ],
                      );
                    }
                );
              }
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async{
      String result = scanData.code;
      print(result);
      if(result.split(' ').length == 2){
        controller.stopCamera();
        EasyLoading.show(status: "Loading...", dismissOnTap: false,maskType: EasyLoadingMaskType.black);
        DetailHistoriAntrianModel detailHistoriAntrianModel = await locator<HomeAppProvider>().getDetailAntrian(idAntrian: result.split(' ')[0].toString());
        EasyLoading.dismiss();
        if(detailHistoriAntrianModel != null){
          Alert(
            context: _globalKey.currentContext,
            type: AlertType.none,
            image: Image.asset('images/logo.png'),
            title: "",
            content: Column(
              children: [
                Image.asset('images/logo.png',width: 150,),
                vSpace(16),
                Text("Detail Antrian", style: TextStyle(fontWeight: FontWeight.normal),),
                vSpace(8),
                Text(detailHistoriAntrianModel.data.antrian.antrianNo.toString(), style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                vSpace(8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Instansi", style: TextStyle(fontSize: 14, color: Colors.grey),),
                  subtitle: Text(detailHistoriAntrianModel.data.instansi.namaInstansi, style: TextStyle(fontSize: 16,color: Colors.black)),
                ),
                vSpace(8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Layanan", style: TextStyle(fontSize: 14, color: Colors.grey),),
                  subtitle: Text(detailHistoriAntrianModel.data.jenisLayanan.jlNama, style: TextStyle(fontSize: 16,color: Colors.black)),
                ),
                vSpace(8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Loket", style: TextStyle(fontSize: 14, color: Colors.grey),),
                  subtitle: Text(detailHistoriAntrianModel.data.jenisLayanan.jlNama+" - "+detailHistoriAntrianModel.data.antrian.antrianLoket, style: TextStyle(fontSize: 16,color: Colors.black)),
                ),
              ],
            ),
            buttons: [
              DialogButton(
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () => Navigator.pop(_globalKey.currentContext),
                width: 120,
              )
            ],
          ).show();
        }else{
          EasyLoading.showToast('antrian tidak ditemukan');
          controller.resumeCamera();
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
