package com.Unity.Tools;
 
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.support.v4.content.FileProvider;
import android.widget.Toast;
import java.io.File;
 
public class UTool {
    private static UTool _instance;
    public static UTool Instance()
    {
        if(null == _instance)
            _instance = new UTool();
        return _instance;
    }
    private Context context;
 
    public void Init(Context context)
    {
        this.context = context;
    }
   
    public void InstallApk(String apkFullPath)
    {
        try
        {
            File file = new File(apkFullPath);
            if (null == file){
                return;
            }
            if (!file.exists()){
                return;
            }
            Intent intent = new Intent(Intent.ACTION_VIEW);
 
            Uri apkUri =null;
            if(Build.VERSION.SDK_INT>=24)
            {
                intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                apkUri = FileProvider.getUriForFile(context, context.getPackageName()+".fileprovider", file);
                //intent.setDataAndType(apkUri, "application/vnd.android.package-archive");
            }else{
                apkUri = Uri.fromFile(file);
                intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            }
            intent.setDataAndType(apkUri, "application/vnd.android.package-archive");
            Toast.makeText(context, apkUri.getPath(), Toast.LENGTH_LONG).show();
            context.startActivity(intent);
        }
        catch (Exception e)
        {
            Toast.makeText(context, e.getMessage(), Toast.LENGTH_LONG).show();
            e.printStackTrace();
        }
    }
}