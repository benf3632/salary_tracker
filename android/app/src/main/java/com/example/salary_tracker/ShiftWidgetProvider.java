package com.example.salary_tracker;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.widget.RemoteViews;
import android.widget.Toast;

public class ShiftWidgetProvider extends AppWidgetProvider {
    public static String WIDGET_BUTTON  = "com.example.salary_tracker.WIDGET_BUTTON";

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        final int N = appWidgetIds.length;

        for (int i = 0; i < N; i++) {
            int appWidgetId = appWidgetIds[i];
            Intent intent = new Intent(WIDGET_BUTTON);
            PendingIntent pendingIntent = PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);

            RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.shift_appwidget);
            views.setOnClickPendingIntent(R.id.buttonStop, pendingIntent);
            appWidgetManager.updateAppWidget(appWidgetId, views);
        }
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        AppWidgetManager mgr = AppWidgetManager.getInstance(context);
        if (WIDGET_BUTTON.equals(intent.getAction())) {
            Toast.makeText(context, "WORKEDDD", Toast.LENGTH_LONG).show();
        }
        super.onReceive(context, intent);
    }
}
