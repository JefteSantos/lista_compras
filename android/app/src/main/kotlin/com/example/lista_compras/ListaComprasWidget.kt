package com.example.lista_compras

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.app.PendingIntent
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Widget nativo Android para a tela inicial.
 * Recebe dados do Flutter via SharedPreferences (home_widget package)
 * e os exibe no layout lista_compras_widget.xml.
 */
class ListaComprasWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            // Lê os dados salvos pelo Flutter via home_widget usando o helper do próprio plugin
            val widgetData = HomeWidgetPlugin.getData(context)
            val listasAtivas   = widgetData.getInt("listas_ativas", 0)
            val itensPendentes = widgetData.getInt("itens_pendentes", 0)
            val totalValor     = widgetData.getString("total_valor", "R\$ 0,00") ?: "R\$ 0,00"
            val horaAtual      = widgetData.getString("ultima_atualizacao", "--:--") ?: "--:--"

            // Monta a RemoteView com os dados atualizados
            val views = RemoteViews(context.packageName, R.layout.lista_compras_widget)
            views.setTextViewText(R.id.widget_listas, listasAtivas.toString())
            views.setTextViewText(R.id.widget_itens, itensPendentes.toString())
            views.setTextViewText(R.id.widget_total, totalValor)
            views.setTextViewText(R.id.widget_hora, horaAtual)

            // Toque no widget abre o app
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
