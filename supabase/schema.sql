-- 모아 · 세특 학습 도우미: Supabase 스키마
-- Supabase 대시보드 > SQL Editor 에서 이 파일 전체를 붙여넣고 Run 하세요.

create table if not exists files (
  id bigint generated always as identity primary key,
  title text not null,
  ext text not null default 'hwp',
  subject text default '',
  term text default '',
  date date not null default current_date,
  topic text default '',
  activity text default '',
  feeling text default '',
  curious text default '',
  created_at timestamptz not null default now()
);

create table if not exists boards (
  id text primary key,
  name text not null,
  joined boolean not null default false,
  member int not null default 0
);

create table if not exists posts (
  id bigint generated always as identity primary key,
  board_id text not null references boards(id) on delete cascade,
  kind text not null,
  cls text default '',
  title text not null,
  body text not null default '',
  author text default '',
  date text default '',
  created_at timestamptz not null default now()
);

create table if not exists comments (
  id bigint generated always as identity primary key,
  post_id bigint not null references posts(id) on delete cascade,
  parent_id bigint references comments(id) on delete cascade,
  who text not null,
  txt text not null,
  created_at timestamptz not null default now()
);

alter table files enable row level security;
alter table boards enable row level security;
alter table posts enable row level security;
alter table comments enable row level security;

-- 프로토타입용 정책: publishable(anon) 키로 모두 읽기/쓰기 허용
-- (실제 로그인을 붙이기 전까지는 이 링크를 아는 사람은 누구나 데이터를 쓰고 지울 수 있어요)
create policy "public read files" on files for select using (true);
create policy "public insert files" on files for insert with check (true);
create policy "public update files" on files for update using (true);
create policy "public delete files" on files for delete using (true);

create policy "public read boards" on boards for select using (true);
create policy "public update boards" on boards for update using (true);

create policy "public read posts" on posts for select using (true);

create policy "public read comments" on comments for select using (true);
create policy "public insert comments" on comments for insert with check (true);
create policy "public delete comments" on comments for delete using (true);

-- ===== 초기 데이터 (지금 프로토타입에 들어있는 데이터 그대로) =====

insert into boards (id, name, joined, member) values
  ('chem', '화학', true, 32),
  ('calc', '미적분Ⅰ', true, 28),
  ('info', '정보', true, 24),
  ('kor', '국어', false, 30),
  ('eng', '영어', false, 31),
  ('bio', '생명과학', false, 19)
on conflict (id) do nothing;

insert into files (title, ext, subject, term, date, topic, activity, feeling, curious) values
  ('산화환원 반응 탐구 보고서', 'hwp', '화학', '2학년 1학기', '2026-05-12',
   '산화환원 반응에서 전자의 이동과 지시약 색 변화 관찰',
   '전자의 이동으로 산화와 환원을 설명하는 실험을 직접 설계하고 진행했다. 지시약의 색 변화를 관찰해 반응이 일어나는 순간을 기록했다.',
   '지시약 색 변화가 예상과 달라 원인을 다시 찾아본 과정이 기억에 남는다. 실험은 예상대로만 흘러가지 않는다는 걸 배웠고, 변수를 통제하는 게 왜 중요한지 체감했다.',
   '온도나 농도를 바꾸면 반응 속도가 어떻게 달라지는지 더 실험해보고 싶다.'),
  ('정적분의 활용 발표자료', 'pptx', '미적분Ⅰ', '2학년 1학기', '2026-06-03',
   '정적분을 이용한 넓이 계산의 실생활 적용',
   '넓이를 구하는 정적분 개념을 실생활 예시로 바꿔 발표자료를 만들었다.',
   '추상적인 공식이 실제 넓이 계산에 쓰인다는 걸 알고 나니 개념이 훨씬 잘 와닿았다.',
   ''),
  ('프롬프트 인젝션 방어 조사', 'pdf', '정보', '2학년 1학기', '2026-06-20',
   'LLM 프롬프트 인젝션 공격 원리와 다층 방어 기법',
   'LLM이 공격에 뚫리는 원리를 조사하고, 방어 기법을 여러 층으로 쌓아야 한다는 점을 정리했다.',
   '단일 방어로는 쉽게 우회된다는 게 인상 깊었다. 내 진로인 정보보안과 가장 맞닿은 활동이라 특히 몰입했다.',
   '실제로 간단한 방어 코드를 직접 짜서 우회가 되는지 테스트해보고 싶다.'),
  ('동아리 활동 사진', 'jpg', '정보', '2학년 1학기', '2026-07-01', '', '', '', '');

do $$
declare
  p1 bigint; p2 bigint; p3 bigint; p4 bigint; p5 bigint; p6 bigint;
  cc1 bigint; cc2 bigint;
begin
  insert into posts (board_id, kind, cls, title, body, author, date) values
    ('chem','수행','A반','3단원 산화환원 실험 보고서','A반 수행평가입니다. 실험 과정과 결과 분석 포함해서 A4 2장 이내로 작성하세요. 다음 주 금요일 수업 시간에 제출.','20101 홍길동','9/8')
    returning id into p1;
  insert into posts (board_id, kind, cls, title, body, author, date) values
    ('chem','수행','D반','D반 수행평가 일정 정리','D반은 다음 주 수요일 실험, 그 주 금요일까지 보고서 제출이에요. A반이랑 날짜 다르니까 헷갈리지 마세요.','20423 박민준','9/6')
    returning id into p2;
  insert into posts (board_id, kind, cls, title, body, author, date) values
    ('chem','시험','','중간고사 시험범위 (공통)','1단원 전체 ~ 3단원 산화환원까지. 교과서 탐구 문제 위주로 나온다고 하셨습니다. 반 상관없이 공통이에요.','20101 홍길동','9/4')
    returning id into p3;
  insert into posts (board_id, kind, cls, title, body, author, date) values
    ('calc','시험','','중간고사 시험범위','수열의 극한부터 정적분의 활용까지. 교과서 예제·유제 다시 풀어보는 걸 추천해요.','20217 정수빈','9/5')
    returning id into p4;
  insert into posts (board_id, kind, cls, title, body, author, date) values
    ('calc','안내','B반','B반 보충 자료 공유','지난 시간에 어려워했던 정적분 넓이 문제 풀이 정리해서 자료실에 올려뒀어요.','20217 정수빈','9/1')
    returning id into p5;
  insert into posts (board_id, kind, cls, title, body, author, date) values
    ('info','안내','','프로젝트 발표 순서','다음 주 수요일부터 조별 발표 시작합니다. 순서는 곧 정해서 공지할게요.','20510 강하은','9/2')
    returning id into p6;

  insert into comments (post_id, parent_id, who, txt) values (p1, null, '20115 김철수', '보고서 양식 따로 있나요?') returning id into cc1;
  insert into comments (post_id, parent_id, who, txt) values (p1, cc1, '20101 홍길동', '자유 양식이래요. 대신 실험 과정은 꼭 넣으라고 하셨어요.');
  insert into comments (post_id, parent_id, who, txt) values (p1, null, '20122 이영희', '손글씨로 써도 되는지 물어봐야겠다');
  insert into comments (post_id, parent_id, who, txt) values (p1, null, '20510 변지유', '실험 결과표도 첨부해야 하나요?');

  insert into comments (post_id, parent_id, who, txt) values (p3, null, '20308 최지우', '프린트 내용도 포함인가요') returning id into cc2;
  insert into comments (post_id, parent_id, who, txt) values (p3, cc2, '20101 홍길동', '네 나눠주신 프린트도 범위래요');
end $$;
