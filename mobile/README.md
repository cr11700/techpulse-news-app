# tech_pulse

A new Flutter project.

# 开发

## 数据库

### 触发器：当用户注册时，自动向数据库public.user插入一条记录
```sql
/**
* This trigger automatically creates a user entry when a new user signs up via Supabase Auth.
*/ 
create or replace function public.handle_new_user() 
returns trigger as $$
begin
  insert into public.user (uid, name)
  values (new.id, '用户' || left(new.id::text, 13));
  return new;
end;

$$ language plpgsql security definer;
create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
```
