package com.example.salary_tracker;

import android.content.Context;
import android.os.Bundle;
import android.widget.Button;
import android.widget.Toast;

import io.flutter.app.FlutterActivity;
import io.flutter.app.FlutterFragmentActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterFragmentActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

  }
}
