(local utils (require :config.utils))

((. (require :which-key) :add) [
	{ 1 "<leader>s" :group "[S]earch" }
	{ 1 "<leader>g" :group  "[G]oto" }
	{ 1 "<leader>c" :group  "[C]onfig" }
	{ 1 "<leader>t" :group  "[T]oggle" }
	{ 1 "<leader>d" :group  "[D]ocument" }
	{ 1 "<leader>w" :group  "[W]orkspace" }
	{ 1 "<leader>o" :group  "[O]verseer" }
])

(local builtin (require :telescope.builtin))
(local kset vim.keymap.set)

(kset "n" "<leader>sf" builtin.find_files { :desc "[S]earch [F]iles" })
(kset "n" "<leader>sg" builtin.live_grep { :desc "[S]earch [G]rep" })
(kset "n" "<leader>sb" builtin.buffers { :desc "[S]earch [B]uffers" })
(kset "n" "<leader>sh" builtin.help_tags { :desc "[S]earch [H]elp Tags" })
(kset "n" "<leader>sr" builtin.resume { :desc "[S]earch [R]esume" })
(kset "n" "<leader>sn" (lambda []
	(builtin.find_files { :cwd (vim.fn.stdpath "config") })
) { :desc "[S]earch [N]eovim files" })
(kset "n" "<leader>ss" builtin.lsp_document_symbols { :desc "[S]earch Document [S]ymbols" })

(kset "n" "<Esc>" "<cmd>nohlsearch<CR>")
(kset "n" "<leader>q" vim.diagnostic.setloclist { :desc "Open diagnostic [Q]uickfix list" })
(kset "t" "<Esc><Esc>" "<C-\\><C-n>" { :desc "Exit terminal mode" })

(case (io.popen "odin root" "r")
  file (let [odin_root (file:read "*a")]
         (file:close)
            (kset "n" "<leader>sof" (lambda []
                (builtin.find_files { :cwd odin_root :prompt_title "Search Odin Files" })
            ) { :desc "[S]earch [O]din [F]iles" })
            (kset "n" "<leader>sog" (lambda []
                (builtin.live_grep { :cwd odin_root :prompt_title "Grep Odin Files" })
            ) { :desc "[S]earch [O]din [G]rep" })
         )
  nil nil)

(local loop (or vim.uv vim.loop))
(if (loop.fs_stat "/usr/src/linux")
    ((lambda []
      (kset "n" "<leader>slf" (lambda []
                                          (builtin.find_files { :cwd "/usr/src/linux/" :prompt_title "Search Linux Files" }))
                      { :desc "[S]earch [L]inux [F]iles" })
      (kset "n" "<leader>slg" (lambda []
                                          (builtin.live_grep { :cwd "/usr/src/linux/" :prompt_title "Grep Linux Files" }))
                      { :desc "[S]earch [L]inux [G]rep" }))))

(vim.api.nvim_create_user_command
  "OverseerRestartLast"
  (lambda []
    (let [overseer (require :overseer)]
      (let [tasks (overseer.list_tasks {:recent_first true})]
        (if (vim.tbl_isempty tasks)
            (vim.notify "No tasks found" vim.log.levels.WARN)
            (overseer.run_action (. tasks 1) "restart")
        )))
    )
  {})

(kset "n" "<leader>or" "<ESC>:OverseerRun<CR>" { :desc "[O]verseer [R]un" })
(kset "n" "<leader>orl" "<ESC>:OverseerRestartLast<CR>" { :desc "[O]verseer [R]un [L]ast" })
(kset "n" "<leader>b" "<ESC>:OverseerRestartLast<CR>" { :desc "Overseer Run Last" })

(kset "n" "<leader>cs" (lambda [] (set package.loaded nil) (vim.cmd (.. "source " (..
                                   (vim.fn.stdpath "config") "/init.lua")))) { :desc "[C]onfig [S]ource" })
(kset "n" "<leader><leader>" "source" { :desc "Source current file." })
(kset "n" "<leader>cfs" (lambda []
                          (let [name (vim.api.nvim_buf_get_name 0)]
                            (let [lua-name (utils.change-extension name :lua)]
                              (vim.cmd (.. "source " lua-name))))) { :desc "[C]onfig [F]ile [S]ource" })

nil
