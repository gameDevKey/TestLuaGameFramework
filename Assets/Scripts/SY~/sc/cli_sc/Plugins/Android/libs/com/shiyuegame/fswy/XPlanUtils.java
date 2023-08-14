package com.shiyuegame.fswy;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.UUID;
import java.util.Vector;

import android.bluetooth.BluetoothAdapter;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;

public class XPlanUtils {
	private static final String TAG = "slg";

	public static boolean createSDCardDir(String dircetory) {
		boolean flag = false;
		String sDStateString = android.os.Environment.getExternalStorageState();
		if (sDStateString.equals(android.os.Environment.MEDIA_MOUNTED)) {
			try {
				File SDFile = android.os.Environment
						.getExternalStorageDirectory();
				File myFile = new File(SDFile.getAbsolutePath()
						+ File.separator + dircetory);
				if (!myFile.exists()) {
					flag = myFile.mkdir();
				} else {
					flag = true;
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		} else {
			Log.e(TAG, "没有SDCard");
		}
		return flag;
	}

	public static boolean IsDirExists(String dircetory) {
		boolean flag = false;
		String sDStateString = android.os.Environment.getExternalStorageState();
		if (sDStateString.equals(android.os.Environment.MEDIA_MOUNTED)) {
			try {
				File SDFile = android.os.Environment
						.getExternalStorageDirectory();
				File myFile = new File(SDFile.getAbsolutePath()
						+ File.separator + dircetory);
				flag = myFile.exists();
			} catch (Exception e) {
				e.printStackTrace();
			}
		} else {
			Log.e(TAG, "没有此目录?" + dircetory);
		}
		return flag;
	}

	public static void setPrefs(Context context, String key, int value) {
		SharedPreferences settings = context.getSharedPreferences("slg.xml", 0);
		SharedPreferences.Editor editor = settings.edit();
		editor.putInt(key, value);
		editor.commit();
	}

	public static void setPrefs(Context context, String key, String value) {
		SharedPreferences settings = context.getSharedPreferences("slg.xml", 0);
		SharedPreferences.Editor editor = settings.edit();
		editor.putString(key, value);
		editor.commit();
	}

	public static int getIntPrefsValue(Context context, String key) {
		SharedPreferences mSettings = context
				.getSharedPreferences("slg.xml", 0);
		int value = mSettings.getInt(key, 0);
		return value;
	}

	public static String getStringPrefsValue(Context context, String key) {
		SharedPreferences mSettings = context
				.getSharedPreferences("slg.xml", 0);
		String value = mSettings.getString(key, "");
		return value;
	}

	public static int checkNet(Context context) {
		ConnectivityManager connectionManager = (ConnectivityManager) context
				.getSystemService("connectivity");
		NetworkInfo networkInfo = connectionManager.getActiveNetworkInfo();
		if (networkInfo != null) {
			if (networkInfo.getType() == ConnectivityManager.TYPE_WIFI) {
				return 1; // 返回1�? WIFI网络
			} else if (networkInfo.getType() == ConnectivityManager.TYPE_MOBILE) {
				return 2; // 返回 2是移动互联网（）
			} else {
				return 3; // 返回3�? 未知网络
			}
		} else {
			return 0;
		}
	}

	public static int checkSDCard(Context context) {
		String sDStateString = android.os.Environment.getExternalStorageState();
		if (sDStateString.equals(android.os.Environment.MEDIA_MOUNTED)) {
			return 1;
		} else {
			return 0;
		}
	}

	/**
	 * 忽略versionCode，统�?返回versionName
	 * 
	 * @author 李志�?
	 * @param context
	 * @return
	 */
	public static String getVersionName(Context context) {
		try {
			String pkName = context.getPackageName();
			String versionName = context.getPackageManager().getPackageInfo(
					pkName, 0).versionName;
			versionName = versionName.split("_")[0];
			return versionName;
		} catch (Exception e) {

		}
		return "";
	}

	/**
	 * 得到string
	 */
	public static String getString(Context context, int id) {
		return context.getResources().getString(id);
	}

	/**
	 * 得到application节点中的META_DATA的�??
	 */
	public static String getMetaData(Context context, String key) {
		try {
			ApplicationInfo appInfo = context.getPackageManager()
					.getApplicationInfo(context.getPackageName(),
							PackageManager.GET_META_DATA);
			return appInfo.metaData.getString(key);
		} catch (NameNotFoundException e) {
			e.printStackTrace();
		}
		return null;
	}

	/**
	 * 从assets里获取图�?
	 * 
	 * @author 李志�?
	 * @param context
	 * @param fileName
	 * @return
	 */
	public static Bitmap getImageFromAssets(Context context, String fileName) {
		Bitmap image = null;
		AssetManager manager = context.getAssets();
		try {
			InputStream in = manager.open(fileName);
			image = BitmapFactory.decodeStream(in);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
		return image;
	}

	public static boolean isExistsFile(Context context, String dirName,
			String fileName) {
		AssetManager manager = context.getAssets();
		try {
			String[] aryFiles = manager.list(dirName);
			Log.i("mlzj", "数量:" + aryFiles.length);
			for (String str : aryFiles) {
				// Log.i("mlzj", "file:" + str);
				if (str.endsWith(fileName)) {
					return true;
				}
			}
		} catch (Exception ex) {
			ex.printStackTrace();
			return false;
		}
		return false;
	}

	/**
	 * 读取Asset里的文本文件
	 * 
	 * @param context
	 * @param fileName
	 * @return
	 */
	public static String getTextFromAssets(Context context, String fileName) {
		StringBuilder sb = new StringBuilder();
		AssetManager manager = context.getAssets();
		try {
			InputStream in = manager.open(fileName);
			InputStreamReader reader = new InputStreamReader(in);
			BufferedReader br = new BufferedReader(reader);

			String line = null;
			while ((line = br.readLine()) != null) {
				sb.append(line);
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}
		return sb.toString();
	}

	/**
	 * 统计Asset文件个数
	 * 
	 * @author 张玉�?
	 * @param context
	 * @param assetDir
	 * @param vector
	 */
	public static void getAssetsFiles(Context context, String assetDir,
			Vector<String> vector) {
		String[] files;
		try {
			files = context.getAssets().list(assetDir);
		} catch (IOException e1) {
			return;
		}
		for (int i = 0; i < files.length; i++) {
			String fileName = files[i];
			if (!fileName.contains(".")) {
				if (0 == assetDir.length()) {
					getAssetsFiles(context, fileName, vector);
				} else {
					getAssetsFiles(context, assetDir + "/" + fileName, vector);
				}
				continue;
			}
			if (0 != assetDir.length())
				vector.add(assetDir + "/" + fileName);
			else
				vector.add(fileName);
		}
	}

	public static void updateApkFromGooglePlay(final Context context,
			final String appPackageName) {
		// WebView webView = new WebView(context);
		// LayoutParams p = new LayoutParams(LayoutParams.MATCH_PARENT,
		// LayoutParams.MATCH_PARENT);
		// webView.setLayoutParams(p);
		// webView.setWebViewClient(new WebViewClient() {
		// @Override
		// public boolean shouldOverrideUrlLoading(WebView view, String url) {
		// Uri uri = Uri.parse("market://details?id=" + appPackageName);
		// Intent viewIntent = new Intent(Intent.ACTION_VIEW, uri);
		// context.startActivity(viewIntent);
		// return true;// super.shouldOverrideUrlLoading(view, url)
		// }
		// });
		Uri uri = Uri.parse("market://details?id=" + appPackageName);
		Intent viewIntent = new Intent(Intent.ACTION_VIEW, uri);
		context.startActivity(viewIntent);
	}

	public static void updateApkFromDown(final Context context, final String url) {
		Uri uri = Uri.parse(url);
		Intent viewIntent = new Intent(Intent.ACTION_VIEW, uri);
		// viewIntent.setDataAndType(Uri.fromFile(new File(url)),
		// "application/vnd.android.package-archive");
		viewIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		viewIntent.setData(uri);
		context.startActivity(viewIntent);
	}

	public static void chmod(String permission, String path) {
		try {
			String command = "chmod " + permission + " " + path;
			Runtime runtime = Runtime.getRuntime();
			runtime.exec(command);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * 判断字符串是否为�?
	 * 
	 * @param str
	 * @return
	 */
	public static boolean isNullOrEmpty(String str) {
		return str == null || str.equals("");
	}


	private static String getAndroidID(Context ctx) {
		String id = Settings.Secure.getString(ctx.getContentResolver(),
				Settings.Secure.ANDROID_ID);
		return id == null ? "" : id;
	}

	public static String getDeviceUUid(Context ctx) {
//		String androidId = getAndroidID(ctx);
//		UUID deviceUuid = new UUID(androidId.hashCode(), ((long) androidId.hashCode() << 32));
//		UUID deviceUuid = UUID.randomUUID();
//		int machineId = 1;//�?大支�?1-9个集群机器部�?  
//	    int hashCodeV = deviceUuid.hashCode();  
//	    if(hashCodeV < 0) {//有可能是负数  
//	        hashCodeV = - hashCodeV;  
//	    }  
//	    // 0 代表前面补充0       
//	    // 4 代表长度�?4       
//	    // d 代表参数为正数型  
//	    return machineId + String.format("%015d", hashCodeV);
		
		UUID deviceUuid = UUID.randomUUID();
		return deviceUuid.toString().replace("-", "");
	}

	public static String readCpuInfo() {
		String result = "";
		try {
			String[] args = { "/system/bin/cat", "/proc/cpuinfo" };
			ProcessBuilder cmd = new ProcessBuilder(args);

			Process process = cmd.start();
			StringBuffer sb = new StringBuffer();
			String readLine = "";
			BufferedReader responseReader = new BufferedReader(
					new InputStreamReader(process.getInputStream(), "utf-8"));
			while ((readLine = responseReader.readLine()) != null) {
				sb.append(readLine);
			}
			responseReader.close();
			result = sb.toString().toLowerCase();
		} catch (IOException ex) {
		}
		return result;
	}

	/**
	 * 判断cpu是否为电脑来判断 模拟�?
	 * 
	 * @return true 为模拟器
	 */
	public static boolean checkIsNotRealPhone() {
		String cpuInfo = readCpuInfo();
		if ((cpuInfo.contains("intel") || cpuInfo.contains("amd"))) {
			return true;
		}
		return false;
	}

	/**
	 * 根据部分特征参数设备信息来判断是否为模拟�?
	 * 
	 * @return true 为模拟器
	 */
	public static boolean isFeatures() {
		return Build.FINGERPRINT.startsWith("generic")
				|| Build.FINGERPRINT.toLowerCase().contains("vbox")
				|| Build.FINGERPRINT.toLowerCase().contains("test-keys")
				|| Build.MODEL.contains("google_sdk")
				|| Build.MODEL.contains("Emulator")
				|| Build.MODEL.contains("Android SDK built for x86")
				|| Build.MANUFACTURER.contains("Genymotion")
				|| (Build.BRAND.startsWith("generic") && Build.DEVICE
						.startsWith("generic"))
				|| "google_sdk".equals(Build.PRODUCT);
	}

	/**
	 * 判断是否存在光传感器来判断是否为模拟�? 部分真机也不存在温度和压力传感器。其余传感器模拟器也存在�?
	 * 
	 * @return true 为模拟器
	 */
	public static Boolean notHasLightSensorManager(Context context) {
		SensorManager sensorManager = (SensorManager) context
				.getSystemService(Context.SENSOR_SERVICE);
		Sensor sensor8 = sensorManager.getDefaultSensor(Sensor.TYPE_LIGHT); // �?
		if (null == sensor8) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * 判断蓝牙是否有效来判断是否为模拟�?
	 * 
	 * @return true 为模拟器
	 */
	public static boolean notHasBlueTooth() {
		BluetoothAdapter ba = BluetoothAdapter.getDefaultAdapter();
		if (ba == null) {
			return true;
		} else {
			// 如果有蓝牙不�?定是有效的�?�获取蓝牙名称，若为null 则默认为模拟�?
			String name = ba.getName();
			if (TextUtils.isEmpty(name)) {
				return true;
			} else {
				return false;
			}
		}
	}
}
