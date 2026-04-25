defmodule Mfin.Photolib do
  import Ecto.Query
  alias Mfin.Repo
  alias Mfin.Photolib.Picture
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
    case maybe_format_convert(path, filename_orig) do
      {:ok, filename} ->
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
      {:error, efname} ->
        Logger.error("Error in file convert #{inspect(efname)}")
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
    case File.exists?(path <> "/view/" <> rootname <> new_ext) or not is_convertible(extension) do
      true ->
        File.rename(path <> "/new/" <> filename, path <> "/view/" <> rootname <> extension)
        ret = make_preview(path <> "/view/", rootname, new_ext)
        {ret, rootname <> new_ext}
      false ->
        {:error, rootname <> new_ext}
    end
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
         {:ok, preview_img} <- Image.thumbnail(img, 300)
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

  def get_pictures(params \\ %{}) do
    from(m in Picture)
    |> maybe_where(params)
    |> maybe_limit(params)
    |> maybe_offset(params)
    |> order_by({:asc, :id})
    |> Repo.all()
  end

  def get_previews(params \\ %{}) do
    pl = from(m in Picture)
        |> select([m], {m.picture})
        |> maybe_where(params)
        |> maybe_limit(params)
        |> maybe_offset(params)
        |> order_by({:asc, :id})
        |> Repo.all()

    for {pname} <- pl, do: make_preview_name(pname)
  end

  def get_gallery(params \\ %{}) do
    pl = from(m in Picture)
        |> select([m], {m.picture, m.meta})
        |> maybe_where(params)
        |> maybe_limit(params)
        |> maybe_offset(params)
        |> order_by([m], asc: m.exif_date, asc: m.id)
        |> Repo.all()

    for {pname, meta} <- pl, do: {make_preview_name(pname), pname, meta}

  end

  @doc """
  SELECT
    EXTRACT(YEAR FROM exif_date) AS year,
    EXTRACT(MONTH FROM exif_date) AS month,
    count(id)
    FROM photolib
    GROUP by year, month
    order by year, month
  """
  def get_pre_gallery() do
    from(m in Picture,
      select: %{ 
        year: selected_as(fragment("EXTRACT(YEAR FROM exif_date)"), :year), 
        month: selected_as(fragment("EXTRACT(MONTH FROM exif_date)"), :month), 
        cnt: selected_as(fragment("count(id)"), :cnt)
      },
      group_by: [selected_as(:year), selected_as(:month)],
      order_by: [selected_as(:year), selected_as(:month)]
    ) |> Repo.all()

  end

  def maybe_limit(query, %{limit: limit}) do
      limit(query, ^limit)
  end
  def maybe_limit(query, _), do: query

  def maybe_offset(query, %{offset: offset}) do
      offset(query, ^offset)
  end
  def maybe_offset(query, _), do: query
  
  def maybe_where(query, _), do: query

  def make_preview_name(name) do
    Path.rootname(name) <> "_p_200" <> Path.extname(name)
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
