defmodule Mfin.Photolib do
  import Ecto.Query
  alias Mfin.Repo
  require Logger

  @photolib_path  "./photolib"

  def import(path \\ @photolib_path) do
    import_path = path <> "/new"  
    case File.ls(import_path) do
      {:ok, lst} ->
        for picture <- lst do
          #process_import(path, picture)
          Mfin.Workers.PhotolibJobs.set_job(path, picture)
        end
      _ -> :ok
    end
  end

  def process_import(path, filename_orig) do
    # check if file already exists
    {:ok, filename} = maybe_format_convert(path, filename_orig)
    {:ok, img} = Image.open(path <> "/view/" <> filename)
    dhash = case Image.dhash(img) do
      {:ok, dh} -> dh
      _ -> nil
    end
    case Mfin.Photolib.Picture.is_already_exists(path, filename, dhash) do
      :already_exists ->
        Logger.info("Picture already exists: #{inspect(filename)} -> #{inspect(dhash)}")
        :ok
      :not_exists ->
        mdata = case Image.exif(img) do
          {:ok, md} -> md
          _ -> %{}
        end
        #Logger.info("Picture: #{inspect(filename)} -> #{inspect(mdata)}")
        exif_date = Kernel.get_in(mdata, [:exif, :datetime_original])

        Mfin.Photolib.Picture.insert_picture(%{
          picture: filename,
          dhash: dhash,
          meta: mdata,
          exif_date: exif_date
        })
    end
  end

  def maybe_format_convert(path, filename) do
    rootname = Path.rootname(filename)
    extension = String.downcase(Path.extname(filename))

    new_ext = case is_convertible(extension) do
      true ->
        System.cmd("vips", ["jpegsave", 
          path <> "/new/" <> filename, 
          path <> "/view/" <> rootname <> ".jpg",
          "-Q", "90"
        ])
        ".jpg"
      false ->
        extension
    end
    File.rename(path <> "/new/" <> filename, path <> "/view/" <> rootname <> extension)
    ret = make_preview(path <> "/view/", rootname, extension)
    {ret, rootname <> new_ext}
  end

  defp is_convertible(".heic"), do: true
  defp is_convertible(_), do: false

  def make_preview(path, rootname, ".heic"), do: make_preview(path, rootname, ".jpg")
  def make_preview(path, rootname, extension) do
    p200 = path <> rootname <> "_p_200" <> extension
  
    iimg = path <> rootname <> extension
    Logger.info("MP!!: #{inspect(p200)} --> #{inspect("MP IMPG: #{inspect(iimg)}")}")

    with false <- File.exists?(p200),
         {:ok, img} <- Image.open(path <> rootname <> extension),
         {:ok, preview_img} <- Image.thumbnail(img, 200)
    do
      Image.write(preview_img, p200)
      :ok
    else
      true ->
        Logger.info("preview already exists")
        :ok
      error ->
        Logger.info("preview error => #{inspect(error)}")
        :error
    end

  end

end

defimpl Jason.Encoder, for: Image.Exif.Gps do
  @impl Jason.Encoder
  def encode(value, opts) do
    # Convert the struct to a map for encoding, or format fields
    map_value = Map.from_struct(value)
    Jason.Encode.map(map_value, opts)
  end
end
