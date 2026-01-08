(local utils (require :config.utils))

((. (require :which-key) :add) [
    { 1 "<leader>s" :group "[S]earch" }
    { 1 "<leader>g" :group "[G]oto" }
    { 1 "<leader>c" :group "[C]onfig" }
    { 1 "<leader>d" :group "[D]ocument" }
    { 1 "<leader>w" :group "[W]orkspace" }
    { 1 "<leader>o" :group "[O]verseer" }
    { 1 "<leader>p" :group "[P]roject" }
    { 1 "<leader>t" :group "[T]erminal" }
])

(local builtin MiniPick.builtin)
(local kset vim.keymap.set)

; terminal
(kset "n" "<leader>tt" (lambda [] (vim.cmd "tab term")) { :desc "Open new [T]erminal in [T]ab" })

; search

(kset "n" "<leader>sf" (lambda [] (builtin.files)) { :desc "[S]earch [F]iles" })
(kset "n" "<leader>sg" (lambda [] (builtin.grep_live)) { :desc "[S]earch [G]rep" })
(kset "n" "<leader>sb" (lambda [] (builtin.buffers)) { :desc "[S]earch [B]uffers" })
(kset "n" "<leader>sh" (lambda [] (builtin.help)) { :desc "[S]earch [H]elp Tags" })
(kset "n" "<leader>sr" (lambda [] (builtin.resume)) { :desc "[S]earch [R]esume" })
(kset "n" "<leader>sn" (lambda []
    (builtin.files {} { :source { :cwd (vim.fn.stdpath "config") }})
) { :desc "[S]earch [N]eovim files" })
; (kset "n" "<leader>ss" builtin.lsp_document_symbols { :desc "[S]earch Document [S]ymbols" })

(kset "n" "<Esc>" "<cmd>nohlsearch<CR>")
(kset "n" "<leader>q" vim.diagnostic.setloclist { :desc "Open diagnostic [Q]uickfix list" })
(kset "t" "<Esc><Esc>" "<C-\\><C-n>" { :desc "Exit terminal mode" })

(case (io.popen "odin root" "r")
  file (let [odin_root (file:read "*a")]
         (file:close)
            (kset "n" "<leader>sof" (lambda []
                (builtin.files {} { :source { :cwd odin_root :prompt_title "Search Odin Files" }})
            ) { :desc "[S]earch [O]din [F]iles" })
            (kset "n" "<leader>sog" (lambda []
                (builtin.grep_live {} { :source { :cwd odin_root :prompt_title "Grep Odin Files" }})
            ) { :desc "[S]earch [O]din [G]rep" })
         )
  nil nil)

(local loop (or vim.uv vim.loop))
(if (loop.fs_stat "/usr/src/linux")
    ((lambda []
      (kset "n" "<leader>slf" (lambda []
                                          (builtin.find_files {} { :source { :cwd "/usr/src/linux/" :prompt_title "Search Linux Files" }}))
                      { :desc "[S]earch [L]inux [F]iles" })
      (kset "n" "<leader>slg" (lambda []
                                          (builtin.grep_live {} { :source { :cwd "/usr/src/linux/" :prompt_title "Grep Linux Files" }}))
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
(kset "n" "<leader>f" MiniFiles.open { :desc "[F]iles" })
(kset "n" "<leader>pf" (lambda [] (MiniFiles.open nil false)) { :desc "[P]roject [F]iles" })

(local harpoon (require :harpoon))
(local mini-pick (require :mini.pick))

(kset "n" "<C-e>"
      (lambda []
        (MiniPick.start {
                         :source {
                          :items (icollect [_ v (ipairs (. (harpoon:list) :items))] (. v :value))
                          :show (lambda [buf_id items query]
                                  (mini-pick.default_show buf_id items query { :show_icons true }))
                          :name "Harpoon"
                         }
                        })) { :desc "List all Harpoon files." })

(kset "n" "<leader>a" (lambda [] (: (harpoon:list) :add)) { :desc "[A]dd to Harpoon list." })
(kset "n" "<C-h>" (lambda [] (: (harpoon:list) :select 1)) { :desc "Select item 1 in the Harpoon list." })
(kset "n" "<C-j>" (lambda [] (: (harpoon:list) :select 2)) { :desc "Select item 2 in the Harpoon list." })
(kset "n" "<C-k>" (lambda [] (: (harpoon:list) :select 3)) { :desc "Select item 3 in the Harpoon list." })
(kset "n" "<C-l>" (lambda [] (: (harpoon:list) :select 4)) { :desc "Select item 4 in the Harpoon list." })
(kset "n" "<C-S-P>" (lambda [] (: (harpoon:list) :prev)) { :desc "Select next item in the Harpoon list." })
(kset "n" "<C-S-N>" (lambda [] (: (harpoon:list) :next)) { :desc "Select previous item in the Harpoon list." })

nil
