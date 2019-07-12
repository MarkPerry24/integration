package com.example.testapp;

import android.content.Context;
import android.os.AsyncTask;
import android.support.annotation.NonNull;
import android.util.Log;
import android.widget.ArrayAdapter;
import android.widget.Filter;
import org.json.JSONArray;
import org.json.JSONException;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import android.widget.Filterable;

public class AutoSuggestAdapter extends ArrayAdapter<String> implements Filterable
{
    private ArrayList<String> mDataList = new ArrayList<>();
    private String mType; // Available types are: names, companies, first_names, last_names, emails, addresses, colors
	private String APIKey = "iSkwEtRMxzOFzWwoy8GEvsL7DMlpn94Uffrg8ETYMOlrsspEZI7Ck_ElqvevdIxz";
    public AutoSuggestAdapter(Context context, int resource, String type)
    {
        super(context, resource);
        mType = type;
    }

    @Override
    public int getCount()
    {
        return mDataList.size();
    }

    @Override
    public String getItem(int position)
    {
        return mDataList.get(position);
    }

    @Override
    @NonNull
    public Filter getFilter()
    {
        return new Filter()
        {
            @Override
            protected FilterResults performFiltering(CharSequence constraint)
            {
                FilterResults filterResults = new FilterResults();
                if(constraint != null)
                {
                    try
                    {
                        //get data from the web
                        String term = constraint.toString();
                        mDataList = new UpdateList().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, new String[]{term, mType, APIKey}).get();
                    }
                    catch (Exception e)
                    {
                        Log.d("AutoCompleteAdapter", "Exception: " + e);
                    }
                    filterResults.values = mDataList;
                    filterResults.count = mDataList.size();
                }
                return filterResults;
            }

            @Override
            protected void publishResults(CharSequence constraint, FilterResults results)
            {
                if(results != null && results.count > 0)
                {
                    notifyDataSetChanged();
                }
                else
                {
                    notifyDataSetInvalidated();
                }
            }
        };
    }
}

class UpdateList extends AsyncTask<String, Integer, ArrayList<String>>
{
    @Override
    protected ArrayList<String> doInBackground(String... strings)
    {
        ArrayList<String> result = new ArrayList<>();
        HttpURLConnection client = null;
        try
        {
            client = (HttpURLConnection) new URL("https://api.fillaware.com/v1/suggest/" + strings[1] + "?q=" + strings[0] + "&key=" + strings[2]).openConnection();
            client.setRequestMethod("GET");
        }
        catch (IOException e)
        {
            Log.e("AutoSuggestAdapter", "HttpConnection exception: " + e);
        }

        StringBuilder string = new StringBuilder();

        try
        {
            BufferedReader reader = new BufferedReader(new InputStreamReader(client.getInputStream()));
            String line;
            while((line = reader.readLine()) != null)
            {
                string.append(line).append('\n');
            }
        }
        catch (IOException e)
        {
           Log.e("AutoSuggestAdapter", "Reader exception: " + e);
        }
        finally
        {
            client.disconnect();
        }

        try
        {
            JSONArray json = new JSONArray(string.toString());
            for (int i = 0; i < json.length(); i++)
            {
                result.add(json.getString(i));
            }
        }
        catch (JSONException e)
        {
            Log.e("AutoSuggestAdapter", "JSON exception: " + e);
        }

        return result;
    }
}