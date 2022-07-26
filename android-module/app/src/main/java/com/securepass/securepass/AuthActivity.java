
package com.securepass.securepass;

import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.nfc.NfcAdapter;
import android.nfc.Tag;
import android.nfc.tech.IsoDep;
import android.os.AsyncTask;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;

import net.sf.scuba.smartcards.CardFileInputStream;
import net.sf.scuba.smartcards.CardService;

import org.jmrtd.BACKey;
import org.jmrtd.BACKeySpec;
import org.jmrtd.PassportService;
import org.jmrtd.lds.SODFile;
import org.jmrtd.lds.CardAccessFile;
import org.jmrtd.lds.SecurityInfo;
import org.jmrtd.lds.icao.DG14File;
import org.jmrtd.lds.icao.DG1File;
import org.jmrtd.lds.icao.DG2File;
import org.jmrtd.lds.icao.MRZInfo;
import org.jmrtd.lds.iso19794.FaceImageInfo;
import org.jmrtd.lds.iso19794.FaceInfo;

import org.jmrtd.lds.PACEInfo;

import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.InputStream;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.Locale;

import static org.jmrtd.PassportService.DEFAULT_MAX_BLOCKSIZE;
import static org.jmrtd.PassportService.NORMAL_MAX_TRANCEIVE_LENGTH;

import io.flutter.embedding.android.FlutterActivity;

public class AuthActivity extends FlutterActivity {

    private static final String TAG = AuthActivity.class.getSimpleName();

    private final static String KEY_PASSPORT_NUMBER = "passportNumber";
    private final static String KEY_EXPIRATION_DATE = "expirationDate";
    private final static String KEY_BIRTH_DATE = "birthDate";
    private String passportNumber ="";
    private String dateofbirth ="";
    private String dateofexpiry ="";
    private String photo64;
    private boolean passportNumberFromIntent = false;
    private boolean encodePhotoToBase64 = false;
    private View mainLayout;
    private View loadingLayout;

    SharedPreferences preferences;

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_auth);
        Bundle extras = getIntent().getExtras();
        if (extras != null) {

            this.passportNumber= extras.getString("passportNumber");
            this.dateofbirth = extras.getString("dateofbirth");
            this.dateofexpiry = extras.getString("dateofexpiry");

        }

         preferences = this.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);


        String dateOfBirth =  dateofbirth;
        String dateOfExpiry = dateofexpiry;
        String passportNumber = this.passportNumber;
        encodePhotoToBase64 = getIntent().getBooleanExtra("photoAsBase64", false);

        if (dateOfBirth != null) {
            PreferenceManager.getDefaultSharedPreferences(this)
                .edit().putString(KEY_BIRTH_DATE, dateOfBirth).apply();
        }
        if (dateOfExpiry != null) {
            PreferenceManager.getDefaultSharedPreferences(this)
                    .edit().putString(KEY_EXPIRATION_DATE, dateOfExpiry).apply();
        }
        if (passportNumber != null) {
            PreferenceManager.getDefaultSharedPreferences(this)
                    .edit().putString(KEY_PASSPORT_NUMBER, passportNumber).apply();
            passportNumberFromIntent = true;
        }


        mainLayout = findViewById(R.id.main_layout);
        loadingLayout = findViewById(R.id.loading_layout);


    }

    @Override
    protected void onResume() {
        super.onResume();

        NfcAdapter adapter = NfcAdapter.getDefaultAdapter(this);
        if (adapter != null) {
            Intent intent = new Intent(getApplicationContext(), this.getClass());
            intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
            PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_MUTABLE);
            String[][] filter = new String[][]{new String[]{"android.nfc.tech.IsoDep"}};
            adapter.enableForegroundDispatch(this, pendingIntent, null, filter);
        }

        if (passportNumberFromIntent) {

            getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();

        NfcAdapter adapter = NfcAdapter.getDefaultAdapter(this);
        if (adapter != null) {
            adapter.disableForegroundDispatch(this);
        }
    }

    private static String convertDate(String input) {
        if (input == null) {
            return null;
        }
        try {
            return new SimpleDateFormat("yyMMdd", Locale.US)
                    .format(new SimpleDateFormat("yyyy-MM-dd", Locale.US).parse(input));
        } catch (ParseException e) {
            Log.w(AuthActivity.class.getSimpleName(), e);
            return null;
        }
    }

    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        if (NfcAdapter.ACTION_TECH_DISCOVERED.equals(intent.getAction())) {
            Tag tag = intent.getExtras().getParcelable(NfcAdapter.EXTRA_TAG);
            if (Arrays.asList(tag.getTechList()).contains("android.nfc.tech.IsoDep")) {
                SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
                String passportNumber = preferences.getString(KEY_PASSPORT_NUMBER, null);
                String expirationDate = convertDate(preferences.getString(KEY_EXPIRATION_DATE, null));
                String birthDate = convertDate(preferences.getString(KEY_BIRTH_DATE, null));
                if (passportNumber != null && !passportNumber.isEmpty()
                        && expirationDate != null && !expirationDate.isEmpty()
                        && birthDate != null && !birthDate.isEmpty()) {
                    BACKeySpec bacKey = new BACKey(passportNumber, birthDate, expirationDate);
                    new ReadTask(IsoDep.get(tag), bacKey).execute();
                    mainLayout.setVisibility(View.GONE);
                    loadingLayout.setVisibility(View.VISIBLE);
                } else {

                }
            }
        }
    }

    private static String exceptionStack(Throwable exception) {
        StringBuilder s = new StringBuilder();
        String exceptionMsg = exception.getMessage();
        if (exceptionMsg != null) {
            s.append(exceptionMsg);
            s.append(" - ");
        }
        s.append(exception.getClass().getSimpleName());
        StackTraceElement[] stack = exception.getStackTrace();

        if (stack.length > 0) {
            int count = 3;
            boolean first = true;
            boolean skip = false;
            String file = "";
            s.append(" (");
            for (StackTraceElement element : stack) {
                if (count > 0 && element.getClassName().startsWith("com.tananaev")) {
                    if (!first) {
                        s.append(" < ");
                    } else {
                        first = false;
                    }

                    if (skip) {
                        s.append("... < ");
                        skip = false;
                    }

                    if (file.equals(element.getFileName())) {
                        s.append("*");
                    } else {
                        file = element.getFileName();
                        s.append(file.substring(0, file.length() - 5)); // remove ".java"
                        count -= 1;
                    }
                    s.append(":").append(element.getLineNumber());
                } else {
                    skip = true;
                }
            }
            if (skip) {
                if (!first) {
                    s.append(" < ");
                }
                s.append("...");
            }
            s.append(")");
        }
        return s.toString();
    }

    private class ReadTask extends AsyncTask<Void, Void, Exception> {

        private IsoDep isoDep;
        private BACKeySpec bacKey;

        private ReadTask(IsoDep isoDep, BACKeySpec bacKey) {
            this.isoDep = isoDep;
            this.bacKey = bacKey;
        }

        private DG1File dg1File;
        private DG2File dg2File;
        private DG14File dg14File;
        private SODFile sodFile;
        private String imageBase64;
        private Bitmap bitmap;
        private boolean chipAuthSucceeded = false;
        private boolean passiveAuthSuccess = false;

        private byte[] dg14Encoded = new byte[0];



        @Override
        protected Exception doInBackground(Void... params) {
            try {
                CardService cardService = CardService.getInstance(isoDep);
                cardService.open();

                PassportService service = new PassportService(cardService, NORMAL_MAX_TRANCEIVE_LENGTH, DEFAULT_MAX_BLOCKSIZE, false, false);
                service.open();

                boolean paceSucceeded = false;
                try {
                    CardAccessFile cardAccessFile = new CardAccessFile(service.getInputStream(PassportService.EF_CARD_ACCESS));
                    Collection<SecurityInfo> securityInfoCollection = cardAccessFile.getSecurityInfos();
                    for (SecurityInfo securityInfo : securityInfoCollection) {
                        if (securityInfo instanceof PACEInfo) {
                            PACEInfo paceInfo = (PACEInfo) securityInfo;
                            service.doPACE(bacKey, paceInfo.getObjectIdentifier(), PACEInfo.toParameterSpec(paceInfo.getParameterId()), null);
                            paceSucceeded = true;
                        }
                    }
                } catch (Exception e) {
                    Log.w(TAG, e);
                }

                service.sendSelectApplet(paceSucceeded);

                if (!paceSucceeded) {
                    try {
                        service.getInputStream(PassportService.EF_COM).read();
                    } catch (Exception e) {
                        service.doBAC(bacKey);
                    }
                }

                CardFileInputStream dg1In = service.getInputStream(PassportService.EF_DG1);
                dg1File = new DG1File(dg1In);

                CardFileInputStream dg2In = service.getInputStream(PassportService.EF_DG2);
                dg2File = new DG2File(dg2In);

                CardFileInputStream sodIn = service.getInputStream(PassportService.EF_SOD);
                sodFile = new SODFile(sodIn);


                List<FaceImageInfo> allFaceImageInfos = new ArrayList<>();
                List<FaceInfo> faceInfos = dg2File.getFaceInfos();
                for (FaceInfo faceInfo : faceInfos) {
                    allFaceImageInfos.addAll(faceInfo.getFaceImageInfos());
                }

                if (!allFaceImageInfos.isEmpty()) {
                    FaceImageInfo faceImageInfo = allFaceImageInfos.iterator().next();

                    int imageLength = faceImageInfo.getImageLength();
                    DataInputStream dataInputStream = new DataInputStream(faceImageInfo.getImageInputStream());
                    byte[] buffer = new byte[imageLength];
                    dataInputStream.readFully(buffer, 0, imageLength);
                    InputStream inputStream = new ByteArrayInputStream(buffer, 0, imageLength);

                    bitmap = ImageUtil.decodeImage(
                            AuthActivity.this, faceImageInfo.getMimeType(), inputStream);

                    imageBase64 = ImageUtil.encodeToBase64(bitmap);

                }

            } catch (Exception e) {
                return e;
            }
            return null;
        }

        @Override
        protected void onPostExecute(Exception result) {
            mainLayout.setVisibility(View.VISIBLE);
            loadingLayout.setVisibility(View.GONE);

            if (result == null) {

                Intent intent;
                if (getCallingActivity() != null) {
                    intent = new Intent();
                } else {

                }

                MRZInfo mrzInfo = dg1File.getMRZInfo();




                photo64 = imageBase64;



                if (getCallingActivity() != null) {
                    finish();
                } else {
                    preferences.edit().putString("flutter.photoBase64", imageBase64).commit();
                    viewResult(mrzInfo.getSecondaryIdentifier().replace("<", " "), mrzInfo.getPrimaryIdentifier().replace("<", " ") , mrzInfo.getGender().name(),mrzInfo.getNationality(), mrzInfo.getDateOfBirth(), mrzInfo.getDocumentNumber(),mrzInfo.getDateOfExpiry(),mrzInfo.getIssuingState());
              // test2();
                }

            } else {
                viewException(exceptionStack(result));
            }
        }

    }

    void  viewResult(String firstName ,String lastName ,String gender, String nationality,String birthDate,String passportNumber ,String expiryDate,String issuingState) {
        String route = String.format("/result?firstName=%s&lastName=%s&gender=%s&nationality=%s&birthDate=%s&passportNumber=%s&expiryDate=%s&issuingState=%s" ,firstName,lastName,gender,nationality,birthDate,passportNumber,expiryDate,issuingState);

        startActivity(
                FlutterActivity
                        .withNewEngine()
                        .initialRoute(route)
                        .build(this)
        );
    }

    void  viewException(String exception) {
        String route = String.format("/exceptionView?exception=%s" ,exception);

        startActivity(
                FlutterActivity
                        .withNewEngine()
                        .initialRoute(route)
                        .build(this)
        );
    }








}
