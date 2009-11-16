public class ChanPhoto {
    public string filename;
}


public class ChanThread {
    public int photo_count;
    public string name;
    public string id;
    public List<ChanPhoto> photos = new List<ChanPhoto>();
}
