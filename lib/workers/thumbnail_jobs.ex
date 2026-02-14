defmodule Mfin.Workers.ThumbnailJobs do
  use Oban.Worker, queue: :thumbnails
  require Logger

  alias Mfin.Blog

  @impl Oban.Worker
  def perform(job) do
    fname = job.args["fname"]
    Logger.info("================ TJ =================== #{inspect(fname)} ")
    
    dirname = Path.dirname(fname)
    basename = Path.basename(fname)
    rootname = Path.rootname(basename)
    extension = Path.extname(basename)

    make_previews(fname, dirname, rootname, String.downcase(extension))
    Logger.info("==TJ1== #{inspect(dirname)}  #{inspect(basename)} #{inspect(rootname)} #{inspect(extension)} ")

    :ok
  end

  defp make_previews(fname, dirname, rootname, ".heic") do
    fnamejpg = dirname <> "/" <> rootname  <> ".jpg"
    System.cmd("vips", ["copy", fname, fnamejpg])
    make_previews(fnamejpg, dirname, rootname, ".jpg")
  end
  defp make_previews(fname, dirname, rootname, extension) do
    File.mkdir(dirname <> "/preview")

    p200 = dirname <> "/preview/" <> rootname <> "_p_200" <> preview_ext(extension)

    with false <- File.exists?(p200),
         {:ok, img} <- Image.open(fname),
         {:ok, preview_img} <- Image.thumbnail(img, 200)
    do
      Logger.info("==TJ2==> #{inspect(p200)}")
      Image.write(preview_img, p200)
    else
      error ->
        Logger.info("==TJ3==error => #{inspect(error)}")
    end

  end

  defp preview_ext(".HEIC"), do: ".jpg"
  defp preview_ext(".heic"), do: ".jpg"
  defp preview_ext(ext), do: ext

  def set_job(post, []), do: post
  def set_job(post, nil), do: post
  def set_job(post, documents) do
    folder = "./uploads/blog_documents/"
    for d <- documents do 
        jb = %{ 
          fname: folder <> "#{d.id}/#{d.file.file_name}" 
        }
        
        Mfin.Workers.ThumbnailJobs.new(jb)
        |> Oban.insert()
    end

    post
  end
end
