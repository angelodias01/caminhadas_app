import 'package:caminhadas_odemira/controllers/atividade_controller.dart';
import 'package:caminhadas_odemira/controllers/caminhada_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AtividadeController & CaminhadaController - Testes de Unidade', () {
    final atividadeController = AtividadeController();
    final caminhadaController = CaminhadaController();

    group('Cálculo de Pontos:', () {
      test('Deve atribuir 1 ponto por cada 100 passos completos (Arredondado por defeito)', () {
        expect(atividadeController.calcularPontos(100), equals(1));
        expect(atividadeController.calcularPontos(250), equals(2));
        expect(atividadeController.calcularPontos(1050), equals(10));
      });

      test('Deve retornar 0 pontos se os passos forem inferiores a 0', () {
        expect(atividadeController.calcularPontos(-50), equals(0));
      });

      test('Deve retornar 0 pontos se os passos ultrapassarem o limite de 50.000', () {
        expect(atividadeController.calcularPontos(50001), equals(0));
        expect(atividadeController.calcularPontos(60000), equals(0));
      });

      test('Deve garantir consistência entre AtividadeController e CaminhadaController', () {
        expect(caminhadaController.calcularPontos(1000), equals(atividadeController.calcularPontos(1000)));
      });
    });

    group('Cálculo de Quilómetros:', () {
      test('Deve converter passos em km com base na passada média (0.00075 km/passo)', () {
        // 10.000 passos * 0.00075 = 7.5 km
        expect(atividadeController.calcularQuilometros(10000), equals(7.5));
      });

      test('Deve arredondar o resultado para apenas uma casa decimal', () {
        // 1350 passos * 0.00075 = 1.0125 -> Deve arredondar para 1.0
        expect(atividadeController.calcularQuilometros(1350), equals(1.0));

        // 5500 passos * 0.00075 = 4.125 -> Deve arredondar para 4.1
        expect(atividadeController.calcularQuilometros(5500), equals(4.1));
      });

      test('Deve retornar 0.0 km se o número de passos for igual ou inferior a zero', () {
        expect(atividadeController.calcularQuilometros(0), equals(0.0));
        expect(atividadeController.calcularQuilometros(-100), equals(0.0));
      });
    });
  });
}