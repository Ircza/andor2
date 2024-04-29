-- Notes
-- (select auth.uid()) is an optimization, described here: https://supabase.com/docs/guides/database/postgres/row-level-security#call-functions-with-select


-- USER --------------------------------------------


-- Profiles --

alter table public.profiles enable row level security;

create policy "READ for everyone" on public.profiles for select to public using (true);
create policy "ALL to user's profile" on public.profiles for all to authenticated using (id = (select auth.uid()));

-- Bookmarks --

alter table public.bookmarks enable row level security;

create policy "ALL to user's bookmarks" on public.bookmarks for all to authenticated using (user_id = (select auth.uid()));
create policy "ALL for storytellers, game joining" on public.bookmarks for all to authenticated using (is_storyteller(game_id));


-- BOARDS --------------------------------------------


alter table public.boards enable row level security;

create policy "READ for everyone" on public.boards for select using (true);
create policy "ALL for owner" on public.boards for all to authenticated using (owner = (select auth.uid()));


-- GAMES --------------------------------------------


alter table public.games enable row level security;

create policy "READ for everyone" on public.games for select to public using (true);
create policy "ALL for owner" on public.games for all to authenticated using (owner = (select auth.uid()));

-- Characters --

alter table public.characters enable row level security;

create policy "READ for everyone in open game" on public.characters for select to public using (game in (select id from games where open_game = true));
create policy "READ for players in closed game" on public.characters for select to authenticated using (is_player(game));
create policy "READ for open characters" on public.characters for select to public using (open = true);
create policy "ALL to user's characters" on public.characters for all to authenticated using (player = (select auth.uid()));
create policy "ALL for storytellers in their game" on public.characters for all to authenticated using (is_storyteller(game));

-- Codex sections --

alter table public.codex_sections enable row level security;

create policy "READ for everyone in open codex" on public.codex_sections for select to public using (game in (select id from games where open_codex = true));
create policy "READ for players in closed codex" on public.codex_sections for select to authenticated using (is_player(game));
create policy "ALL for storytellers in their game" on public.codex_sections for all to authenticated using (is_storyteller(game));

-- Codex pages --

alter table public.codex_pages enable row level security;

create policy "READ for everyone in open codex" on public.codex_pages for select to public using (game in (select id from games where open_codex = true));
create policy "READ for players in closed codex" on public.codex_pages for select to authenticated using (is_player(game));
create policy "ALL for storytellers in their game" on public.codex_pages for all to authenticated using (is_storyteller(game));

-- Maps --

alter table public.maps enable row level security;

create policy "READ for everyone in open game" on public.maps for select to public using (game in (select id from games where open_game = true));
create policy "READ for players in closed game" on public.maps for select to authenticated using (is_player(game));
create policy "UPDATE for players in closed game" on public.maps for update to authenticated using (is_player(game));
create policy "ALL for storytellers in their game" on public.maps for all to authenticated using (is_storyteller(game));


-- WORKS --------------------------------------------


alter table public.works enable row level security;

create policy "READ for everyone" on public.works for select to public using (true);
create policy "ALL for owners" on public.works for all to authenticated using (owner = (select auth.uid()));


-- GENERAL --------------------------------------------


-- Threads --

alter table public.threads enable row level security;

create policy "READ for everyone" on public.threads for select to public using (true);
create policy "INSERT for authenticated" on public.threads for insert to authenticated with check (true); -- thread creation doesn't work otherwise
create policy "ALL for owners" on public.threads for all to authenticated using (is_thread_owner(id));

-- Posts --

alter table public.posts enable row level security;

create policy "ALL for owners" on public.posts for all to authenticated using (owner = (select auth.uid()));
create policy "ALL for character owners" on public.posts for all to authenticated using (is_players_character(owner));
create policy "INSERT for players or users" on public.posts for insert to authenticated with check (thread in (select thread from boards union select thread from works union select discussion_thread as thread from games where is_player(id) union select game_thread as thread from games where is_player(id)));
create policy "INSERT for users to chat" on public.posts for insert to authenticated with check (thread = 1);

  -- games
create policy "READ to everyone in open game and open discussion" on public.posts for select to public using ((thread in (select discussion_thread from games where open_discussion = true)) or (thread in (select game_thread from games where open_game = true)));
create policy "READ to players in closed game and closed discussion" on public.posts for select to authenticated using (thread in (select discussion_thread from games where open_discussion = false and is_player(id)) or thread in (select game_thread from games where open_game = false and is_player(id)));
create policy "ALL for storytellers" on public.posts for all to authenticated using (thread in (select discussion_thread from games where is_storyteller(id)) or thread in (select game_thread from games where is_storyteller(id)));
  -- boards
create policy "READ for users in open boards, except banned" on public.posts for select using (exists (select 1 from boards where boards.open = true and boards.thread = posts.thread and not ((select auth.uid()) = any (boards.bans))));
create policy "READ to members in closed boards" on public.posts for select using (exists (select 1 from boards where boards.open = false and boards.thread = posts.thread and ((select auth.uid()) = boards.owner or (select auth.uid()) = any (boards.members) or (select auth.uid()) = any (boards.mods))));
create policy "ALL for mods and owner in boards" on public.posts for all using (exists (select 1 from boards where boards.thread = posts.thread and ((select auth.uid()) = boards.owner or (select auth.uid()) = any (boards.mods))));
  -- works
create policy "READ to everyone in works" on public.posts for select to public using (thread in (select thread from works));

-- Reactions --

alter table public.reactions enable row level security;

create policy "SELECT for users" on public.reactions for select to authenticated using (true);
create policy "UPDATE for users" on public.reactions for update to authenticated using (true);
create policy "INSERT for users" on public.reactions for insert to authenticated with check (true);

-- Messages --

alter table public.messages enable row level security;

create policy "READ for author and recipient" on public.messages for select to authenticated using ((sender_user = (select auth.uid())) or (recipient_user = (select auth.uid())) or is_players_character(recipient_character) or is_players_character(sender_character));
create policy "UPDATE for recipient" on public.messages for update to authenticated using (recipient_user = (select auth.uid()) or is_players_character(recipient_character));
create policy "ALL for author" on public.messages for all to authenticated using (sender_user = (select auth.uid()) or is_players_character(sender_character));

-- Subscriptions --

alter table public.subscriptions enable row level security;

create policy "ALL for owner" on public.subscriptions for all to authenticated using (user_id = (select auth.uid()));

-- User reads --

alter table public.user_reads enable row level security;

create policy "ALL for owners" on public.user_reads for all to authenticated using (user_id = (select auth.uid()));


-- STORAGE --------------------------------------------

-- Headers
-- Portraits
-- Posts
-- Maps