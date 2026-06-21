package com.example.caminhadas_odemira

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val idCanal = "passos_channel"
            val nomeCanal = "Contagem de Passos"
            val descricaoCanal = "Canal para o serviço de passos em background"
            val importancia = NotificationManager.IMPORTANCE_LOW

            val canal = NotificationChannel(idCanal, nomeCanal, importancia).apply {
                description = descricaoCanal
            }

            val gestorNotificacoes = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            gestorNotificacoes.createNotificationChannel(canal)
        }
    }
}