---
title: "폼은 가능하면 비제어 컴포넌트 사용"
id: rerender-form-uncontrolled
impact: MEDIUM
category: rerender-optimization
impactDescription: "키 입력마다 리렌더 제거 — 폼 성능 5-10x 개선 (많은 필드 시)"
tags: [react, nextjs, performance, rerender, forms, react-hook-form]
---

# 폼은 가능하면 비제어 컴포넌트 사용

> 모든 폼 필드를 useState로 제어하면, 한 글자 입력할 때마다 폼 전체가 리렌더된다. 비제어 컴포넌트(useRef 또는 react-hook-form)를 사용하면 키 입력 시 리렌더가 발생하지 않는다.

## Incorrect

```tsx
// Before: 모든 필드를 useState로 제어 — 한 글자마다 전체 폼 리렌더
function RegistrationForm() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [phone, setPhone] = useState('');
  const [address, setAddress] = useState('');
  const [city, setCity] = useState('');
  const [zipCode, setZipCode] = useState('');
  const [agreeTerms, setAgreeTerms] = useState(false);
  const [newsletter, setNewsletter] = useState(false);

  // 10개 필드 중 하나에 입력할 때마다 전체 컴포넌트 리렌더
  // 각 리렌더마다 10개 input + 유효성 검사 로직 모두 실행

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // 제출 시 모든 state에서 값 수집
    const data = { name, email, password, confirmPassword, phone, address, city, zipCode, agreeTerms, newsletter };
    submitForm(data);
  };

  return (
    <form onSubmit={handleSubmit}>
      <input value={name} onChange={(e) => setName(e.target.value)} placeholder="이름" />
      <input value={email} onChange={(e) => setEmail(e.target.value)} placeholder="이메일" />
      <input value={password} onChange={(e) => setPassword(e.target.value)} type="password" placeholder="비밀번호" />
      <input value={confirmPassword} onChange={(e) => setConfirmPassword(e.target.value)} type="password" placeholder="비밀번호 확인" />
      <input value={phone} onChange={(e) => setPhone(e.target.value)} placeholder="전화번호" />
      <input value={address} onChange={(e) => setAddress(e.target.value)} placeholder="주소" />
      <input value={city} onChange={(e) => setCity(e.target.value)} placeholder="도시" />
      <input value={zipCode} onChange={(e) => setZipCode(e.target.value)} placeholder="우편번호" />
      <label>
        <input type="checkbox" checked={agreeTerms} onChange={(e) => setAgreeTerms(e.target.checked)} />
        이용약관 동의
      </label>
      <label>
        <input type="checkbox" checked={newsletter} onChange={(e) => setNewsletter(e.target.checked)} />
        뉴스레터 구독
      </label>
      <button type="submit">가입</button>
    </form>
  );
}
```

## Correct

```tsx
// After: react-hook-form으로 비제어 — 키 입력 시 리렌더 제로
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const registrationSchema = z.object({
  name: z.string().min(2, '이름은 2자 이상'),
  email: z.string().email('올바른 이메일 형식'),
  password: z.string().min(8, '비밀번호는 8자 이상'),
  confirmPassword: z.string(),
  phone: z.string().regex(/^01\d-\d{4}-\d{4}$/, '전화번호 형식: 01X-XXXX-XXXX'),
  address: z.string().min(1, '주소를 입력하세요'),
  city: z.string().min(1, '도시를 입력하세요'),
  zipCode: z.string().regex(/^\d{5}$/, '우편번호 5자리'),
  agreeTerms: z.literal(true, { errorMap: () => ({ message: '이용약관 동의 필수' }) }),
  newsletter: z.boolean(),
}).refine((data) => data.password === data.confirmPassword, {
  message: '비밀번호가 일치하지 않습니다',
  path: ['confirmPassword'],
});

type RegistrationData = z.infer<typeof registrationSchema>;

function RegistrationForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<RegistrationData>({
    resolver: zodResolver(registrationSchema),
    defaultValues: {
      newsletter: false,
      agreeTerms: false as unknown as true,
    },
  });

  // register()가 ref 기반으로 DOM을 직접 관리 — 타이핑 시 리렌더 없음
  // 유효성 검사는 submit 또는 blur 시에만 실행

  const onSubmit = async (data: RegistrationData) => {
    await submitForm(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div>
        <input {...register('name')} placeholder="이름" />
        {errors.name && <span className="error">{errors.name.message}</span>}
      </div>
      <div>
        <input {...register('email')} placeholder="이메일" />
        {errors.email && <span className="error">{errors.email.message}</span>}
      </div>
      <div>
        <input {...register('password')} type="password" placeholder="비밀번호" />
        {errors.password && <span className="error">{errors.password.message}</span>}
      </div>
      <div>
        <input {...register('confirmPassword')} type="password" placeholder="비밀번호 확인" />
        {errors.confirmPassword && <span className="error">{errors.confirmPassword.message}</span>}
      </div>
      <div>
        <input {...register('phone')} placeholder="전화번호" />
        {errors.phone && <span className="error">{errors.phone.message}</span>}
      </div>
      <div>
        <input {...register('address')} placeholder="주소" />
        {errors.address && <span className="error">{errors.address.message}</span>}
      </div>
      <div>
        <input {...register('city')} placeholder="도시" />
        {errors.city && <span className="error">{errors.city.message}</span>}
      </div>
      <div>
        <input {...register('zipCode')} placeholder="우편번호" />
        {errors.zipCode && <span className="error">{errors.zipCode.message}</span>}
      </div>
      <label>
        <input type="checkbox" {...register('agreeTerms')} />
        이용약관 동의
        {errors.agreeTerms && <span className="error">{errors.agreeTerms.message}</span>}
      </label>
      <label>
        <input type="checkbox" {...register('newsletter')} />
        뉴스레터 구독
      </label>
      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? '가입 중...' : '가입'}
      </button>
    </form>
  );
}
```

## Why

제어 컴포넌트(controlled)는 `onChange → setState → 리렌더 → input value 업데이트` 사이클을 거친다. 10개 필드의 폼에서 한 글자 입력 시 폼 전체(10개 input + 유효성 로직)가 리렌더된다. 빠른 타이핑 시 이 비용이 누적되어 입력 지연(input lag)이 체감된다.

비제어 컴포넌트는 DOM이 자체적으로 input 값을 관리한다. React는 값을 알 필요 없이 submit 시점에만 DOM에서 값을 수집한다.

react-hook-form의 장점:
1. **register()**: ref 기반 비제어 연결 — 타이핑 시 리렌더 제로
2. **유효성 검사**: submit 또는 blur 시에만 실행 (mode 설정 가능)
3. **Zod 통합**: 타입 안전한 스키마 검증
4. **에러 상태**: errors 변경 시에만 해당 필드 리렌더

**정량적 효과:**
- 10개 필드 폼 타이핑: 제어 → 글자당 1회 전체 리렌더 / 비제어 → 0회 리렌더
- React Profiler 기준 폼 인터랙션 렌더 횟수 5-10x 감소
- 저사양 모바일 기기에서 입력 지연(input lag) 해소

## References

- [React Hook Form 공식 문서](https://react-hook-form.com/)
- [React 공식 문서 — Uncontrolled Components](https://react.dev/learn/sharing-state-between-components#controlled-and-uncontrolled-components)
- [React Hook Form + Zod](https://react-hook-form.com/get-started#SchemaValidation)
