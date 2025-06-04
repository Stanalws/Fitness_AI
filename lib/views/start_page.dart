import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import '../routes/slide_route.dart';
import 'registration_page.dart';
import 'profile_page.dart';
import '../main.dart';
import '../services/api_service.dart';
import '../viewmodels/start_viewmodel.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});
  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with RouteAware {
  final _viewModel = StartViewModel();

  void _lockPortrait() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void initState() {
    super.initState();
    _lockPortrait();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewModel.checkAutoLogin(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _lockPortrait();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211111),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 390,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/start_image.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Fitness AI Training',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Lexend-Bold',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Добро пожаловать в Fitness AI Training – ваш персональный тренер '
                      'для домашних тренировок! Здесь вы найдёте программы, составленные '
                      'именно под ваши цели и физические возможности.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Marmelad-Regular',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE51919),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        SlideLeftRoute(page: const RegistrationPage()),
                      );
                    },
                    child: const Text(
                      'Начать !',
                      style: TextStyle(
                        fontFamily: 'Lexend-Bold',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Marmelad-Regular',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    children: [
                      const TextSpan(
                        text:
                        'Перед началом использования приложения рекомендуем ознакомиться с ',
                      ),
                      TextSpan(
                        text: 'Руководством Пользователя',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontFamily: 'Marmelad-Regular',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                final maxHeight =
                                    MediaQuery.of(context).size.height * 0.6;
                                return AlertDialog(
                                  title: const Text('Руководство Пользователя'),
                                  content: SizedBox(
                                    height: maxHeight,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            '1. Если вы являетесь новым пользователем, то вам необходимо пройти регистрацию. '
                                                'В окне регистрации укажите: действительный email-адрес, ваше имя, пароль и подтвердите пароль. '
                                                'Для подтверждения регистрации введите код, пришедший на указанную почту.\n\n'
                                                '2. Если вы уже зарегистрированы, то перейдите в окно авторизации. '
                                                'Укажите ваш зарегистрированный email и пароль. '
                                                'Если вы забыли пароль, нажмите на «Забыли пароль?». '
                                                'В окне восстановления пароля введите новый пароль и подтвердите его. '
                                                'Эти действия также подтверждаются кодом с почты. '
                                                'Если вы не хотите вводить данные при каждом запуске, поставьте галочку «Оставаться в системе» — тогда при следующем запуске вы сразу попадёте в окно профиля.\n\n'
                                                '3. После успешной авторизации вы попадёте в окно профиля, где отображается ваше имя. '
                                                'При желании вы можете изменить имя, нажав на него и введя новое. '
                                                'Для подбора тренировок заполните анкету: введите вес, рост, пол и возраст. '
                                                'Также укажите ограничения по здоровью в разделе «Противопоказания»: выберите из доступных групп (максимум 2 ограничения в группе, всего 3). '
                                                'В настройках профиля вы можете поменять пароль или удалить аккаунт (оба действия подтверждаются кодом с почты). '
                                                'В правом верхнем углу находится кнопка выхода из аккаунта.\n\n'
                                                '4. Вы можете подключить фитнес-трекер: перейдите во вкладку «Трекер» и выберите устройство (смарт-часы или браслет). '
                                                'После подключения вы увидите пульс и количество шагов. '
                                                'Если нажать «Сохранить», данные трекера будут учтены при генерации тренировки и отображаться в профиле.\n\n'
                                                '5. В разделе «Тренировка» находится основной функционал: подбор упражнений на основе ваших данных и данных трекера (если подключено). '
                                                'Для генерации выберите цель. '
                                                'Если вы новичок, приложение выдаст тестовую тренировку. Если вы уже тренируетесь, тренировка подбирается на основе вашей истории. '
                                                'Вы можете менять цель в любой момент. '
                                                'Сгенерированная тренировка отображается в этом же окне: название, список упражнений с указанием подходов или рекомендованной длительности, описание и план выполнения. '
                                                'После выполнения укажите, сколько подходов получилось выполнить, а время упражнений заполняется автоматически. '
                                                'Оцените сложность каждого упражнения от 1 до 5 — иначе тренировка не будет считаться завершённой.\n\n'
                                                '6. В разделе «Результаты» отображается история ваших тренировок. '
                                                'Для последних пяти тренировок строятся графики: как менялся средний пульс, средняя выполнимость упражнений и средняя оценка сложности.',
                                            style: TextStyle(
                                              fontFamily: 'Marmelad-Regular',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Закрыть'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
