((. (require :which-key) :add) [
	{ 1 "<leader>s" :group "[S]earch" }
	{ 1 "<leader>g" :group  "[G]oto" }
	{ 1 "<leader>c" :group  "[C]ode" }
	{ 1 "<leader>t" :group  "[T]oggle" }
	{ 1 "<leader>d" :group  "[D]ocument" }
	{ 1 "<leader>w" :group  "[W]orkspace" }
	{ 1 "<leader>o" :group  "[O]verseer" }
])

(local builtin (require :telescope.builtin))

(vim.keymap.set "n" "<leader>sf" builtin.find_files { :desc "[S]earch [F]iles" })
(vim.keymap.set "n" "<leader>sg" builtin.live_grep { :desc "[S]earch [G]rep" })
(vim.keymap.set "n" "<leader>sb" builtin.buffers { :desc "[S]earch [B]uffers" })
(vim.keymap.set "n" "<leader>sh" builtin.help_tags { :desc "[S]earch [H]elp Tags" })
(vim.keymap.set "n" "<leader>sr" builtin.resume { :desc "[S]earch [R]esume" })
(vim.keymap.set "n" "<leader>sn" (lambda []
	(builtin.find_files { :cwd (vim.fn.stdpath "config") })
) { :desc "[S]earch [N]eovim files" })
(vim.keymap.set "n" "<leader>ss" builtin.lsp_document_symbols { :desc "[S]earch Document [S]ymbols" })

(vim.keymap.set "n" "<Esc>" "<cmd>nohlsearch<CR>")
(vim.keymap.set "n" "<leader>q" vim.diagnostic.setloclist { :desc "Open diagnostic [Q]uickfix list" })
(vim.keymap.set "t" "<Esc><Esc>" "<C-\\><C-n>" { :desc "Exit terminal mode" })

(case (io.popen "odin root" "r")
  file (let [odin_root (file:read "*a")]
         (file:close)
            (vim.keymap.set "n" "<leader>sof" (lambda []
                (builtin.find_files { :cwd odin_root :prompt_title "Search Odin Files" })
            ) { :desc "[S]earch [O]din [F]iles" })
            (vim.keymap.set "n" "<leader>sog" (lambda []
                (builtin.live_grep { :cwd odin_root :prompt_title "Grep Odin Files" })
            ) { :desc "[S]earch [O]din [G]rep" })
         )
  nil nil)

; vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
; vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
; vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
; vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

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

(vim.keymap.set "n" "<leader>or" "<ESC>:OverseerRun<CR>" { :desc "[O]verseer [R]un" })
(vim.keymap.set "n" "<leader>orl" "<ESC>:OverseerRestartLast<CR>" { :desc "[O]verseer [R]un [L]ast" })
(vim.keymap.set "n" "<leader>b" "<ESC>:OverseerRestartLast<CR>" { :desc "Overseer Run Last" })

(local vks vim.keymap.set)
(vks "n" "<leader>cs" (lambda [] (vim.cmd (.. "source " (..
                                   (vim.fn.stdpath "config") "/init.lua")))) { :desc "[C]onfig [S]ource" })

nil
